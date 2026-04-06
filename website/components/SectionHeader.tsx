type SectionHeaderProps = {
  eyebrow: string;
  title: string;
  description: string;
};

export function SectionHeader({ eyebrow, title, description }: SectionHeaderProps) {
  return (
    <div className="space-y-3 text-slate-900">
      <p className="text-sm font-medium uppercase tracking-[0.2em] text-slate-500">{eyebrow}</p>
      <h2 className="text-3xl font-semibold tracking-tight sm:text-4xl">{title}</h2>
      <p className="max-w-3xl text-base leading-7 text-slate-600">{description}</p>
    </div>
  );
}
