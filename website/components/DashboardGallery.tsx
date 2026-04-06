export function DashboardGallery() {
  return (
    <section id="dashboard-showcase" className="mx-auto max-w-6xl px-6 py-16">
      <div className="space-y-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="text-sm font-medium uppercase tracking-[0.2em] text-slate-500">Dashboard Showcase</p>
            <h2 className="mt-2 text-3xl font-semibold tracking-tight text-slate-950 sm:text-4xl">
              BI-ready pages for portfolio and risk monitoring
            </h2>
          </div>
        </div>

        <div className="grid gap-6 md:grid-cols-2">
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6 shadow-sm">
            <h3 className="text-lg font-semibold">Executive Portfolio Overview</h3>
            <p className="mt-3 text-sm leading-6 text-slate-600">
              A high-level summary of exposure, overdue trends, utilization, and concentration across the whole portfolio.
            </p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6 shadow-sm">
            <h3 className="text-lg font-semibold">Customer Risk Monitor</h3>
            <p className="mt-3 text-sm leading-6 text-slate-600">
              Actionable watchlists for deteriorating customers, over-limit cases, and payment behavior signals.
            </p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6 shadow-sm">
            <h3 className="text-lg font-semibold">Receivables & Aging Analysis</h3>
            <p className="mt-3 text-sm leading-6 text-slate-600">
              Aging bucket breakdowns and overdue severity views for collections and credit teams.
            </p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6 shadow-sm">
            <h3 className="text-lg font-semibold">Industry / Country Risk View</h3>
            <p className="mt-3 text-sm leading-6 text-slate-600">
              Segment risk heatmaps for geography, industry, rating, and concentration analysis.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
