export function HeroSection() {
  return (
    <section className="border-b border-slate-200 bg-slate-50">
      <div className="mx-auto grid max-w-6xl gap-10 px-6 py-20 md:grid-cols-2 md:items-center">
        <div>
          <p className="text-sm font-medium uppercase tracking-[0.2em] text-slate-500">
            Portfolio Project
          </p>
          <h1 className="mt-4 text-4xl font-semibold tracking-tight text-slate-950 md:text-5xl">
            B2B Credit Risk Analytics Platform
          </h1>
          <p className="mt-6 max-w-xl text-base leading-7 text-slate-600">
            A realistic analytics system for monitoring receivables exposure, overdue behavior,
            credit limit utilization, concentration risk, and customer deterioration across a B2B portfolio.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <a
              href="https://github.com/yourusername/b2b-credit-risk-analytics-platform"
              className="rounded-xl bg-slate-900 px-5 py-3 text-sm font-medium text-white"
            >
              View Repository
            </a>
            <a
              href="#dashboard-showcase"
              className="rounded-xl border border-slate-300 px-5 py-3 text-sm font-medium text-slate-700"
            >
              Explore Dashboards
            </a>
          </div>
        </div>

        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="rounded-2xl bg-slate-50 p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Warehouse</p>
              <p className="mt-2 text-lg font-semibold">PostgreSQL Star Schema</p>
            </div>
            <div className="rounded-2xl bg-slate-50 p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Data</p>
              <p className="mt-2 text-lg font-semibold">Synthetic B2B Receivables</p>
            </div>
            <div className="rounded-2xl bg-slate-50 p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Analytics</p>
              <p className="mt-2 text-lg font-semibold">KPI & Feature Layer</p>
            </div>
            <div className="rounded-2xl bg-slate-50 p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">BI</p>
              <p className="mt-2 text-lg font-semibold">Power BI Monitoring</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
