import { json } from '@sveltejs/kit';
import { clickhouse } from '$lib/clickhouse';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url }) => {
  try {
    const searchTerm = url.searchParams.get('search') || '';
    const limit = parseInt(url.searchParams.get('limit') || '20');
    const page = parseInt(url.searchParams.get('page') || '1');
    const offset = (page - 1) * limit;
    const sortColumn = url.searchParams.get('sort') || '';
    const sortOrder = url.searchParams.get('order') || 'desc';
    
    const result = await clickhouse.searchTransactions(searchTerm, limit, offset, sortColumn, sortOrder);
    return json(result);
  } catch (error) {
    console.error('Error fetching transactions:', error);
    return json({ error: 'Failed to fetch transactions' }, { status: 500 });
  }
};
