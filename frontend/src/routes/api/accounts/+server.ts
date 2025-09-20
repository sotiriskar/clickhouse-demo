import { json } from '@sveltejs/kit';
import { clickhouse } from '$lib/clickhouse';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url }) => {
  try {
    const searchTerm = url.searchParams.get('search') || '';
    const limit = parseInt(url.searchParams.get('limit') || '20');
    
    const result = await clickhouse.searchAccounts(searchTerm, limit);
    return json(result);
  } catch (error) {
    console.error('Error fetching accounts:', error);
    return json({ error: 'Failed to fetch accounts' }, { status: 500 });
  }
};
