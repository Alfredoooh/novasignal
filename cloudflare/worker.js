// ============================================
// CLOUDFLARE WORKER - SISTEMA OTIMIZADO CORRIGIDO
// ============================================

const API_KEYS = [
  'b44c67ad584a39726891c32421edec77847c068cb036edf6a41c4c40d8855f97',
  '5fbf446f332cdcb25ae37e36e1d7edeb55f7a47c7b30f34a8fe23da37f8d6ac0',
  '20e63224b98d436a5cacca064bd40c204f7179171b08212b9cdf6d770cfef3ff'
];

function getCurrentApiKey() {
  const hour = new Date().getUTCHours();
  if (hour >= 0 && hour < 8) return API_KEYS[0];
  if (hour >= 8 && hour < 16) return API_KEYS[1];
  return API_KEYS[2];
}

const LEAGUES = {
  'Premier League': '152',
  'La Liga': '302',
  'Serie A': '207',
  'Bundesliga': '175',
  'Ligue 1': '168',
  'Championship': '149',
  'League One': '148',
  'EFL Cup': '152',
  'La Liga 2': '303',
  'Serie B': '206',
  '2. Bundesliga': '176',
  'Ligue 2': '169',
  'Coupe de France': '168',
  'Primeira Liga': '266',
  'Segunda Liga': '267',
  'Taca da Liga': '266',
  'Taca de Portugal': '266',
  'Eredivisie': '322',
  'First Division A': '244',
  'Super Lig': '203',
  'Allsvenskan': '113',
  'Svenska Cupen': '113',
  'Ekstraklasa': '176',
  '1. HNL': '387',
  'Brasileirao': '99',
  'Copa do Brasil': '99',
  'UEFA Champions League': '3',
  'UEFA Europa League': '4',
  'World Cup Qualification': '28',
  'Africa Cup of Nations': '5',
  'UEFA Nations League': '5'
};

const LEAGUE_IDS = [...new Set(Object.values(LEAGUES))];

export default {
  async scheduled(event, env, ctx) {
    const cronType = event?.cron || null;
    const apiKey = getCurrentApiKey();
    
    console.log('🔄 Cron iniciado:', new Date().toISOString());
    
    try {
      if (cronType === '*/2 * * * *') {
        await updateLiveMatches(env, apiKey);
      }
      if (cronType === '*/5 * * * *') {
        await updateTodayMatches(env, apiKey);
      }
      if (cronType === '*/30 * * * *') {
        await updateTomorrowMatches(env, apiKey);
      }
      
      console.log('✅ Cron finalizado');
      
    } catch (error) {
      console.error('❌ Erro no cron:', error?.message || error);
      try {
        await env.FOOTBALL_CACHE.put(
          'system:last_error',
          JSON.stringify({
            error: (error && error.message) ? error.message : String(error),
            cron: cronType,
            timestamp: new Date().toISOString()
          }),
          { expirationTtl: 3600 }
        );
      } catch (e) {
        console.error('❌ Não foi possível gravar last_error na KV:', e);
      }
    }
  },

  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    let path = url.pathname.replace(/\/+$/,'') || '/';

    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      if (!env.FOOTBALL_CACHE) {
        return jsonResponse({ 
          error: 'KV não configurado'
        }, 500, corsHeaders);
      }

      if (path === '/' || path === '') {
        return jsonResponse({ 
          status: 'online',
          message: 'Worker funcionando!',
          timestamp: new Date().toISOString(),
          version: '2.0'
        }, 200, corsHeaders);
      }

      if (path === '/api/status') {
        const stats = await getSystemStats(env);
        return jsonResponse(stats, 200, corsHeaders);
      }

      if (path === '/api/current-api') {
        const apiKey = getCurrentApiKey();
        const hour = new Date().getUTCHours();
        return jsonResponse({
          current_hour_utc: hour,
          api_period: hour < 8 ? '00:00-08:00' : hour < 16 ? '08:00-16:00' : '16:00-00:00',
          api_key_prefix: apiKey.substring(0, 15) + '...'
        }, 200, corsHeaders);
      }

      if (path === '/api/leagues') {
        return jsonResponse({
          leagues: LEAGUES,
          unique_ids: LEAGUE_IDS,
          total: LEAGUE_IDS.length
        }, 200, corsHeaders);
      }

      if (path === '/api/matches/live') {
        return await getMatchesByPrefix(env, 'live:', corsHeaders);
      }

      if (path === '/api/matches/today') {
        return await getMatchesByPrefix(env, 'today:', corsHeaders);
      }

      if (path === '/api/matches/tomorrow') {
        return await getMatchesByPrefix(env, 'tomorrow:', corsHeaders);
      }

      if (path === '/api/matches') {
        return await getAllMatches(env, corsHeaders);
      }

      if (path.startsWith('/api/matches/') && path.split('/').length >= 4) {
        const matchId = path.split('/')[3];
        
        if (!matchId || matchId === '') {
          return jsonResponse({ error: 'ID inválido' }, 400, corsHeaders);
        }

        return await getMatchById(env, matchId, corsHeaders);
      }

      if (request.method === 'POST' && path === '/api/update/live') {
        const apiKey = getCurrentApiKey();
        await updateLiveMatches(env, apiKey);
        return jsonResponse({ 
          success: true, 
          message: 'Jogos ao vivo atualizados' 
        }, 200, corsHeaders);
      }

      if (request.method === 'POST' && path === '/api/update/today') {
        const apiKey = getCurrentApiKey();
        await updateTodayMatches(env, apiKey);
        return jsonResponse({ 
          success: true, 
          message: 'Jogos de hoje atualizados' 
        }, 200, corsHeaders);
      }

      if (request.method === 'POST' && path === '/api/update/tomorrow') {
        const apiKey = getCurrentApiKey();
        await updateTomorrowMatches(env, apiKey);
        return jsonResponse({ 
          success: true, 
          message: 'Jogos de amanhã atualizados' 
        }, 200, corsHeaders);
      }

      if (request.method === 'DELETE' && path === '/api/cache/clear') {
        const deleted = await clearCache(env);
        return jsonResponse({ 
          success: true, 
          deleted_count: deleted,
          message: 'Cache limpo'
        }, 200, corsHeaders);
      }

      return jsonResponse({ 
        error: 'Rota não encontrada',
        path: path,
        method: request.method,
        available_routes: [
          'GET /',
          'GET /api/status',
          'GET /api/current-api',
          'GET /api/leagues',
          'GET /api/matches',
          'GET /api/matches/live',
          'GET /api/matches/today',
          'GET /api/matches/tomorrow',
          'GET /api/matches/{id}',
          'POST /api/update/live',
          'POST /api/update/today',
          'POST /api/update/tomorrow',
          'DELETE /api/cache/clear'
        ]
      }, 404, corsHeaders);

    } catch (error) {
      console.error('❌ Erro na API:', error?.message || error);
      return jsonResponse({ 
        error: (error && error.message) ? error.message : String(error),
        timestamp: new Date().toISOString()
      }, 500, corsHeaders);
    }
  }
};

async function getMatchesByPrefix(env, prefix, corsHeaders) {
  const list = await env.FOOTBALL_CACHE.list({ prefix });
  const matches = [];
  const keys = list && list.keys ? list.keys : [];

  for (const key of keys) {
    const data = await env.FOOTBALL_CACHE.get(key.name);
    if (data) {
      try {
        matches.push(JSON.parse(data));
      } catch (e) {
        console.error('Erro ao parsear:', key.name);
      }
    }
  }

  const sorted = matches.sort(function(a, b) {
    const timeA = a.match_time ? new Date(a.match_time).getTime() : 0;
    const timeB = b.match_time ? new Date(b.match_time).getTime() : 0;
    return timeA - timeB;
  });

  return jsonResponse({ 
    count: sorted.length,
    matches: sorted
  }, 200, corsHeaders);
}

async function getAllMatches(env, corsHeaders) {
  const prefixes = ['live:', 'today:', 'tomorrow:'];
  const allMatches = [];

  for (const prefix of prefixes) {
    const list = await env.FOOTBALL_CACHE.list({ prefix });
    const keys = list && list.keys ? list.keys : [];
    for (const key of keys) {
      const data = await env.FOOTBALL_CACHE.get(key.name);
      if (data) {
        try {
          allMatches.push(JSON.parse(data));
        } catch (e) {
          console.error('Erro ao parsear:', key.name);
        }
      }
    }
  }

  const sorted = allMatches.sort(function(a, b) {
    const timeA = a.match_time ? new Date(a.match_time).getTime() : 0;
    const timeB = b.match_time ? new Date(b.match_time).getTime() : 0;
    return timeA - timeB;
  });

  return jsonResponse({ 
    count: sorted.length,
    matches: sorted
  }, 200, corsHeaders);
}

async function getMatchById(env, matchId, corsHeaders) {
  for (const prefix of ['live:', 'today:', 'tomorrow:']) {
    const cached = await env.FOOTBALL_CACHE.get(`${prefix}${matchId}`);
    if (cached) {
      return new Response(cached, {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }
  }

  return jsonResponse({ 
    error: 'Partida não encontrada',
    match_id: matchId 
  }, 404, corsHeaders);
}

async function clearCache(env) {
  let deleted = 0;
  const prefixes = ['live:', 'today:', 'tomorrow:', 'system:'];
  
  for (const prefix of prefixes) {
    const list = await env.FOOTBALL_CACHE.list({ prefix });
    const keys = list && list.keys ? list.keys : [];
    for (const key of keys) {
      try {
        await env.FOOTBALL_CACHE.delete(key.name);
        deleted++;
      } catch (e) {
        console.error('Erro ao deletar chave:', key.name, e);
      }
    }
  }
  
  return deleted;
}

async function updateLiveMatches(env, apiKey) {
  console.log('⚡ Atualizando jogos ao vivo...');
  
  try {
    const url = `https://apiv3.apifootball.com/?action=get_events&match_live=1&APIkey=${apiKey}`;
    const response = await fetchWithRetry(url, 3);
    
    if (!response.ok) {
      throw new Error(`API retornou ${response.status}`);
    }

    const liveMatches = await response.json();

    if (!Array.isArray(liveMatches)) {
      await env.FOOTBALL_CACHE.put(
        'system:live_status',
        JSON.stringify({
          has_matches: false,
          checked_at: new Date().toISOString()
        }),
        { expirationTtl: 300 }
      );
      return;
    }

    const filtered = liveMatches.filter(m => 
      LEAGUE_IDS.includes(m.league_id?.toString())
    );

    let saved = 0;
    for (const match of filtered) {
      if (match.match_id) {
        await env.FOOTBALL_CACHE.put(
          `live:${match.match_id}`,
          JSON.stringify({
            ...match,
            cached_at: new Date().toISOString(),
            category: 'live'
          }),
          { expirationTtl: 300 }
        );
        saved++;
      }
    }

    await env.FOOTBALL_CACHE.put(
      'system:live_status',
      JSON.stringify({
        has_matches: true,
        count: saved,
        checked_at: new Date().toISOString()
      }),
      { expirationTtl: 300 }
    );

    console.log(`✅ ${saved} jogos ao vivo salvos`);

  } catch (error) {
    console.error('❌ Erro:', error?.message || error);
    throw error;
  }
}

async function updateTodayMatches(env, apiKey) {
  console.log('📅 Atualizando jogos de hoje...');
  
  try {
    const today = new Date().toISOString().split('T')[0];
    let allMatches = [];
    
    for (const leagueId of LEAGUE_IDS) {
      try {
        const url = `https://apiv3.apifootball.com/?action=get_events&from=${today}&to=${today}&league_id=${leagueId}&APIkey=${apiKey}`;
        const response = await fetchWithRetry(url, 2);

        if (response.ok) {
          const matches = await response.json();
          if (Array.isArray(matches)) {
            allMatches.push(...matches);
          }
        }
        
        await sleep(500);
        
      } catch (e) {
        console.error(`Liga ${leagueId}:`, e);
      }
    }

    let saved = 0;
    for (const match of allMatches) {
      if (match.match_id) {
        await env.FOOTBALL_CACHE.put(
          `today:${match.match_id}`,
          JSON.stringify({
            ...match,
            cached_at: new Date().toISOString(),
            category: 'today'
          }),
          { expirationTtl: 7200 }
        );
        saved++;
      }
    }

    console.log(`✅ ${saved} jogos salvos`);

  } catch (error) {
    console.error('❌ Erro:', error?.message || error);
  }
}

async function updateTomorrowMatches(env, apiKey) {
  console.log('📆 Atualizando jogos de amanhã...');
  
  try {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const date = tomorrow.toISOString().split('T')[0];
    
    let allMatches = [];
    
    for (const leagueId of LEAGUE_IDS) {
      try {
        const url = `https://apiv3.apifootball.com/?action=get_events&from=${date}&to=${date}&league_id=${leagueId}&APIkey=${apiKey}`;
        const response = await fetchWithRetry(url, 2);

        if (response.ok) {
          const matches = await response.json();
          if (Array.isArray(matches)) {
            allMatches.push(...matches);
          }
        }
        
        await sleep(500);
        
      } catch (e) {
        console.error(`Liga ${leagueId}:`, e);
      }
    }

    let saved = 0;
    for (const match of allMatches) {
      if (match.match_id) {
        await env.FOOTBALL_CACHE.put(
          `tomorrow:${match.match_id}`,
          JSON.stringify({
            ...match,
            cached_at: new Date().toISOString(),
            category: 'tomorrow'
          }),
          { expirationTtl: 14400 }
        );
        saved++;
      }
    }

    console.log(`✅ ${saved} jogos salvos`);

  } catch (error) {
    console.error('❌ Erro:', error?.message || error);
  }
}

async function fetchWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url);
      if (response.ok) return response;
      
      if (response.status === 429) {
        await sleep(2000 * (i + 1));
      } else {
        await sleep(1000 * (i + 1));
      }
      
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await sleep(1000 * (i + 1));
    }
  }
  
  throw new Error('Max retries');
}

async function getSystemStats(env) {
  try {
    const liveList = await env.FOOTBALL_CACHE.list({ prefix: 'live:' });
    const todayList = await env.FOOTBALL_CACHE.list({ prefix: 'today:' });
    const tomorrowList = await env.FOOTBALL_CACHE.list({ prefix: 'tomorrow:' });
    
    const liveKeys = liveList && liveList.keys ? liveList.keys : [];
    const todayKeys = todayList && todayList.keys ? todayList.keys : [];
    const tomorrowKeys = tomorrowList && tomorrowList.keys ? tomorrowList.keys : [];
    
    const apiKey = getCurrentApiKey();
    const hour = new Date().getUTCHours();
    
    return {
      status: 'online',
      timestamp: new Date().toISOString(),
      matches: {
        live: liveKeys.length,
        today: todayKeys.length,
        tomorrow: tomorrowKeys.length,
        total: liveKeys.length + todayKeys.length + tomorrowKeys.length
      },
      leagues: {
        configured: LEAGUE_IDS.length
      },
      api: {
        current_hour_utc: hour,
        period: hour < 8 ? '00:00-08:00' : hour < 16 ? '08:00-16:00' : '16:00-00:00',
        key_prefix: apiKey.substring(0, 15) + '...'
      }
    };
    
  } catch (error) {
    return { 
      error: error?.message || String(error),
      timestamp: new Date().toISOString()
    };
  }
}

function jsonResponse(data, status, headers) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: { ...headers, 'Content-Type': 'application/json' }
  });
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}