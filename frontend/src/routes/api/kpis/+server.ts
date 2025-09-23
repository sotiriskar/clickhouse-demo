import { json } from '@sveltejs/kit';
import { clickhouse } from '$lib/clickhouse';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url }) => {
  try {
    const days = parseInt(url.searchParams.get('days') || '7');
    const result = await clickhouse.getDailyKPIs(days);
    return json(result);
  } catch (error) {
    console.error('Error fetching KPIs:', error);
    return json({ error: 'Failed to fetch KPIs' }, { status: 500 });
  }
};
