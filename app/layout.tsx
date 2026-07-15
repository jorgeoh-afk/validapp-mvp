import type { Metadata } from "next";
import { DM_Sans, Geist_Mono } from "next/font/google";
import "./globals.css";

const appSans = DM_Sans({
  variable: "--font-app-sans",
  subsets: ["latin"],
});

const appMono = Geist_Mono({
  variable: "--font-app-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "ValidApp",
  description:
    "Plataforma para prepararte para tu examen de validación de estudios.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="es"
      className={`${appSans.variable} ${appMono.variable} h-full antialiased`}
    >
      <body className="flex min-h-full flex-col bg-zinc-50 dark:bg-black">
        {children}
      </body>
    </html>
  );
}
