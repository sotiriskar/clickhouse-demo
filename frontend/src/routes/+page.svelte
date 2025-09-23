<script lang="ts">
  import { onMount } from 'svelte';
  import Dashboard from '$lib/components/Dashboard.svelte';
  import ClickHouseLogo from '$lib/assets/clickhouse-yellow-badge.svg';

  let activeTab = 'gold';

  const tabs = [
    { id: 'gold', label: 'Report', icon: 'fas fa-chart-line' },
    { id: 'analytics', label: 'Analytics', icon: 'fas fa-search' },
    { id: 'sqlpad', label: 'SQLPad', icon: 'fas fa-code' }
  ];

  function setActiveTab(tabId: string) {
    activeTab = tabId;
  }

  // Update page title based on active tab
  $: pageTitle = `ClickHouse Analytics - ${tabs.find(tab => tab.id === activeTab)?.label || 'Dashboard'}`;
</script>

<svelte:head>
  <title>{pageTitle}</title>
</svelte:head>

<div class="dashboard-container">
  <!-- Sidebar -->
  <aside class="sidebar">
    <div class="sidebar-header">
      <div class="clickhouse-badge">
        <img src={ClickHouseLogo} alt="ClickHouse" />
      </div>
    </div>
    
    <nav class="sidebar-nav">
      {#each tabs as tab}
        <button 
          class="nav-item" 
          class:active={activeTab === tab.id}
          on:click={() => setActiveTab(tab.id)}
        >
          <i class="nav-icon {tab.icon}"></i>
          <span class="nav-text">{tab.label}</span>
        </button>
      {/each}
    </nav>
  </aside>

  <!-- Main Content -->
  <div class="main-content">
    <!-- Header -->
    <header class="main-header">
      <div class="header-left">
        <h1 class="page-title">
          {#if activeTab === 'gold'}
            Report Dashboard
          {:else if activeTab === 'analytics'}
            Analytics Dashboard
          {:else if activeTab === 'sqlpad'}
            SQLPad Query Editor
          {/if}
        </h1>
        <p class="page-subtitle">Data Analytics Platform</p>
      </div>
      
      <div class="header-right">
        <!-- Search removed -->
      </div>
    </header>

    <!-- Content Area -->
    <main class="content-area">
      <Dashboard {activeTab} />
    </main>
  </div>
</div>

<style>
  .dashboard-container {
    display: flex;
    min-height: 100vh;
    background: #f8fafc;
    font-family: 'Roboto', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  }

  /* Sidebar */
  .sidebar {
    width: 280px;
    background: #ffffff;
    border-right: 1px solid #e2e8f0;
    display: flex;
    flex-direction: column;
    position: fixed;
    height: 100vh;
    left: 0;
    top: 0;
    z-index: 100;
  }

  .sidebar-header {
    padding: 1rem;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 120px;
  }

  .clickhouse-badge {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 80px;
    height: 80px;
    border-radius: 16px;
    overflow: hidden;
  }

  .clickhouse-badge img {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }

  .sidebar-nav {
    padding: 1rem;
    flex: 1;
  }

  .nav-item {
    width: 100%;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1rem;
    margin-bottom: 0.25rem;
    border: none;
    background: none;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.2s ease;
    color: #64748b;
    font-size: 1.1rem;
    font-weight: 500;
    text-align: left;
  }

  .nav-item:hover {
    background: #f8fafc;
    color: #1e293b;
  }

  .nav-item.active {
    background: #3b82f6;
    color: white;
    font-weight: 500;
  }

  .nav-icon {
    font-size: 1rem;
    width: 20px;
    text-align: center;
  }

  .nav-text {
    flex: 1;
  }

  /* Main Content */
  .main-content {
    flex: 1;
    margin-left: 280px;
    display: flex;
    flex-direction: column;
    overflow-x: hidden;
    max-width: calc(100vw - 280px);
  }

  /* Header */
  .main-header {
    background: #ffffff;
    border-bottom: 1px solid #e2e8f0;
    padding: 1.5rem 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .header-left {
    flex: 1;
  }

  .page-title {
    margin: 0 0 0.25rem 0;
    font-size: 1.875rem;
    font-weight: 400;
    color: #1e293b;
  }

  .page-subtitle {
    margin: 0;
    color: #64748b;
    font-size: 0.95rem;
  }

  .header-right {
    display: flex;
    align-items: center;
    gap: 1.5rem;
  }

  .search-container {
    display: flex;
    align-items: center;
  }

  .search-input {
    padding: 0.5rem 0.75rem;
    border: 1px solid #e2e8f0;
    border-radius: 6px;
    background: #ffffff;
    color: #1e293b;
    font-size: 0.9rem;
    width: 250px;
    transition: all 0.2s ease;
  }

  .search-input:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
  }

  /* Content Area */
  .content-area {
    flex: 1;
    padding: 2rem;
    background: #f8fafc;
    overflow-x: hidden;
    max-width: 100%;
  }

  @media (max-width: 1024px) {
    .sidebar {
      width: 240px;
    }
    
    .main-content {
      margin-left: 240px;
    }
    
    .search-input {
      width: 200px;
    }
  }

  @media (max-width: 768px) {
    .sidebar {
      width: 100%;
      position: relative;
      height: auto;
    }
    
    .main-content {
      margin-left: 0;
    }
    
    .main-header {
      flex-direction: column;
      align-items: stretch;
      gap: 1rem;
    }
    
    .header-right {
      justify-content: space-between;
    }
    
    .search-input {
      width: 100%;
    }
    
    .content-area {
      padding: 1rem;
    }
  }
</style>