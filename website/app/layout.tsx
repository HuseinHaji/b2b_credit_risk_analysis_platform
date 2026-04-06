import type { Metadata } from "next";
import "../globals.css";

export const metadata: Metadata = {
  title: "B2B Credit Risk Analytics Platform",
  description: "Case-study website for a synthetic B2B credit risk analytics platform.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
