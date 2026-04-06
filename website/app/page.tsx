import { HeroSection } from "@/components/HeroSection";
import { SectionHeader } from "@/components/SectionHeader";
import { MetricCard } from "@/components/MetricCard";
import { DashboardGallery } from "@/components/DashboardGallery";
import { siteContent } from "@/data/siteContent";

export default function HomePage() {
  return (
    <main className="min-h-screen bg-white text-slate-900">
      <HeroSection />

      <section className="mx-auto max-w-6xl px-6 py-16">
        <SectionHeader
          eyebrow="Overview"
          title="A realistic credit risk analytics case study"
          description="An end-to-end portfolio project covering synthetic trade receivables data generation, PostgreSQL warehousing, KPI modeling, Power BI dashboarding, and a deployable public case-study website."
        />
        <div className="mt-8 grid gap-6 md:grid-cols-3">
          {siteContent.overviewMetrics.map((item) => (
            <MetricCard
              key={item.label}
              label={item.label}
              value={item.value}
              description={item.description}
            />
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-6 py-16 border-t border-slate-200">
        <SectionHeader
          eyebrow="Business Problem"
          title="Why this platform exists"
          description="B2B credit portfolios require more than transaction storage. They need exposure visibility, aging intelligence, utilization monitoring, and deterioration tracking across customers, sectors, and countries."
        />
        <div className="mt-8 grid gap-6 md:grid-cols-2">
          <div className="rounded-2xl border border-slate-200 p-6 shadow-sm">
            <h3 className="text-lg font-semibold">Operational pain points</h3>
            <ul className="mt-4 space-y-3 text-sm text-slate-600">
              <li>Fragmented invoice and payment data</li>
              <li>Limited visibility into overdue trend deterioration</li>
              <li>No unified credit limit utilization monitoring</li>
              <li>Weak management reporting across industries and countries</li>
            </ul>
          </div>
          <div className="rounded-2xl border border-slate-200 p-6 shadow-sm">
            <h3 className="text-lg font-semibold">Platform outcomes</h3>
            <ul className="mt-4 space-y-3 text-sm text-slate-600">
              <li>Monthly exposure and aging snapshots</li>
              <li>Reusable SQL KPI layer for risk reporting</li>
              <li>Customer watchlists and deterioration monitoring</li>
              <li>BI-ready executive and analyst dashboard design</li>
            </ul>
          </div>
        </div>
      </section>

      <DashboardGallery />

      <footer className="border-t border-slate-200 py-10">
        <div className="mx-auto max-w-6xl px-6 text-sm text-slate-500">
          B2B Credit Risk Analytics Platform — portfolio case study
        </div>
      </footer>
    </main>
  );
}
