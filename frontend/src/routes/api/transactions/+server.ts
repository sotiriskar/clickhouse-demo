import { json } from '@sveltejs/kit';
import { clickhouse } from '$lib/clickhouse';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url }) => {
  try {
    const searchTerm = url.searchParams.get('search') || '';
    const limit = parseInt(url.searchParams.get('limit') || '20');
    
    const result = await clickhouse.searchTransactions(searchTerm, limit);
    return json(result);
  } catch (error) {
    console.error('Error fetching transactions:', error);
    return json({ error: 'Failed to fetch transactions' }, { status: 500 });
  }
};
