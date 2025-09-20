import { json } from '@sveltejs/kit';
import { clickhouse } from '$lib/clickhouse';
import type { RequestHandler } from './$types';

export const POST: RequestHandler = async ({ request }) => {
  try {
    const { sql } = await request.json();
    
    if (!sql || typeof sql !== 'string') {
      return json({ error: 'SQL query is required' }, { status: 400 });
    }

    // Basic SQL injection protection - only allow SELECT statements
    const trimmedSql = sql.trim().toLowerCase();
    if (!trimmedSql.startsWith('select')) {
      return json({ error: 'Only SELECT queries are allowed' }, { status: 400 });
    }

    const result = await clickhouse.executeCustomQuery(sql);
    return json(result);
  } catch (error) {
    console.error('Error executing query:', error);
    const errorMessage = error instanceof Error ? error.message : 'Failed to execute query';
    return json({ error: errorMessage }, { status: 500 });
  }
};
