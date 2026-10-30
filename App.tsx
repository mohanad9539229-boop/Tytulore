import { useCallback, useEffect, useMemo, useState } from "react";
import { ArrowLeft, ShieldCheck, Sparkles, Wand2 } from "lucide-react";
import { accentPresets, carAnims, dances, features, luaFiles, type AccentPreset, type DanceId } from "@/data";
import type { Notify, PreviewTab, ToggleKey, Toggles } from "@/types";
import { downloadText } from "@/utils/files";
import { Footer, PreviewModal, Sidebar, TopNav } from "@/components/Chrome";
import { PreviewPanel } from "@/components/PreviewPanel";
import { CarSection, DanceGrid, Hero } from "@/components/Showcase";
import { ScriptSection, SettingsSection } from "@/components/Studio";
import { Ornament, Pill, SectionHead, Toasts, type ToastItem } from "@/components/ui";

const DEFAULT_TOGGLES: Toggles = {
  notifications: true,
  hideHud: false,
  performance: false,
  autoRepeat: true,
  sound: false,
};

const SECTION_IDS = ["preview", "dances", "garage", "script", "settings"] as const;

export default function App() {
  const [tab, setTab] = useState<PreviewTab>("player");
  const [danceId, setDanceId] = useState<DanceId>("maybach");
  const [carAnimId, setCarAnimId] = useState("maybach");
  const [playing, setPlaying] = useState(true);
  const [speed, setSpeed] = useState(1);
  const [accent, setAccent] = useState<AccentPreset>(accentPresets[0]);
  const [toggles, setToggles] = useState<Toggles>(DEFAULT_TOGGLES);
  const [keybind, setKeybind] = useState("F4");
  const [toasts, setToasts] = useState<ToastItem[]>([]);
  const [modalOpen, setModalOpen] = useState(false);
  const [activeSection, setActiveSection] = useState<string>("preview");

  const dance = useMemo(() => dances.find((d) => d.id === danceId) ?? dances[0], [danceId]);
  const carAnim = useMemo(() => carAnims.find((c) => c.id === carAnimId) ?? carAnims[0], [carAnimId]);

  /* accent + speed as CSS variables */
  useEffect(() => {
    const root = document.documentElement.style;
    root.setProperty("--accent", accent.hex);
    root.setProperty("--accent-soft", accent.soft);
    root.setProperty("--accent-deep", accent.deep);
    root.setProperty("--accent-rgb", accent.rgb);
  }, [accent]);

  useEffect(() => {
    document.documentElement.style.setProperty("--speed", String(speed));
  }, [speed]);

  /* active section tracking */
  useEffect(() => {
    const onScroll = () => {
      const marker = window.scrollY + 150;
      let current: string = SECTION_IDS[0];
      for (const id of SECTION_IDS) {
        const el = document.getElementById(id);
        if (!el) continue;
        const top = el.getBoundingClientRect().top + window.scrollY;
        if (top <= marker) current = id;
      }
      setActiveSection(current);
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll);
    return () => {
      window.removeEventListener("scroll", onScroll);
      window.removeEventListener("resize", onScroll);
    };
  }, []);

  const notify = useCallback<Notify>((title, desc, tone = "success") => {
    const id = Date.now() + Math.random();
    setToasts((prev) => [...prev.slice(-2), { id, title, desc, tone }]);
    window.setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4200);
  }, []);

  const setToggle = useCallback((key: ToggleKey, value: boolean) => {
    setToggles((prev) => ({ ...prev, [key]: value }));
  }, []);

  const handlePlayDance = (id: DanceId) => {
    const next = dances.find((d) => d.id === id);
    setDanceId(id);
    setPlaying(true);
    setTab("player");
    if (toggles.notifications) {
      notify(`تم تشغيل ${next?.name ?? "الحركة"}`, "الحركة تعمل الآن في المعاينة الحية", "success");
    }
    document.getElementById("preview")?.scrollIntoView({ behavior: "smooth", block: "start" });
  };

  const handleDownloadFile = (name: string, code: string) => {
    downloadText(name, code);
  };

  const handleDownloadBundle = () => {
    const header = `--[[
    WIND UI · Cosmetic Roleplay Animation Suite
    الإصدار: 2.4.0
    © 2026 WIND STUDIO

    حزمة تجميلية (Roleplay) فقط — لا تحتوي على Aim Silent
    أو Triggerbot أو Wallhack أو أي أدوات غش.

    طريقة التركيب:
    1) أنشئ مورداً باسم wind-ui داخل مجلد resources
    2) ضع الملفات الثلاثة التالية داخله بنفس الأسماء
    3) أضف السطر التالي إلى server.cfg:
       ensure wind-ui
    4) أضف مجلد stream/ وضع ملفات الديكت داخله
    5) أعد تشغيل السيرفر

    ملاحظة: أسماء الديكت في config.lua يجب أن تطابق
    ملفات الأنيميشن المرفقة في مجلد stream/.
]]

`;
    const body = luaFiles
      .map((f) => `-- ============================================================\n-- ${f.name}\n-- ============================================================\n\n${f.code}`)
      .join("\n\n\n");
    downloadText("wind-ui-2.4.0.lua", header + body);
    notify("بدأ تحميل الحزمة", "wind-ui-2.4.0.lua · 3 ملفات", "success");
  };

  const handleReset = () => {
    setAccent(accentPresets[0]);
    setSpeed(1);
    setToggles(DEFAULT_TOGGLES);
    setKeybind("F4");
    setPlaying(true);
    setDanceId("maybach");
    setCarAnimId("maybach");
    notify("تمت إعادة الضبط", "كل الإعدادات عادت إلى الوضع الافتراضي", "info");
  };

  return (
    <div id="top" className="relative min-h-screen overflow-x-hidden">
      {/* ambient background */}
      <div className="pointer-events-none fixed inset-0 -z-10">
        <div className="absolute inset-0 bg-[#07070a]" />
        <div className="grid-lines absolute inset-0 opacity-70" />
        <div className="absolute -top-48 right-1/4 size-[560px] rounded-full accent-bg opacity-[0.07] blur-[130px]" />
        <div className="absolute top-1/3 -left-40 size-[460px] rounded-full accent-bg opacity-[0.05] blur-[130px]" />
        <div className="absolute right-0 bottom-0 size-[380px] rounded-full accent-bg opacity-[0.04] blur-[120px]" />
      </div>

      <TopNav active={activeSection} onDownload={handleDownloadBundle} />

      <main className="mx-auto max-w-[1480px] px-4 pt-4 lg:px-7">
        <div className="grid gap-6 lg:grid-cols-[248px_minmax(0,1fr)]">
          <Sidebar active={activeSection} dance={dance} playing={playing} onDownload={handleDownloadBundle} />

          <div className="min-w-0 space-y-14 pb-4">
            <Hero
              onDownload={handleDownloadBundle}
              onPreview={() => setModalOpen(true)}
              playing={playing}
              dance={dance}
            />

            {/* live preview */}
            <section id="preview" className="scroll-mt-24">
              <SectionHead
                eyebrow="Live Preview"
                icon={Wand2}
                title={
                  <>
                    جرّب الواجهة <span className="gold-text">بنفسك</span>
                  </>
                }
                desc="لوحة تحكم كاملة تحاكي واجهة WindUI داخل اللعبة — بدّل الرقصة، سرعة الحركة، لون التمييز، وشاهد النتيجة لحظياً."
                action={
                  <div className="flex items-center gap-2">
                    <Pill tone="accent">
                      <Sparkles className="size-2.5" /> تفاعلي
                    </Pill>
                    <button
                      onClick={() => setModalOpen(true)}
                      className="btn-ghost flex items-center gap-1.5 rounded-xl px-3 py-2 text-[11px] text-white/70"
                    >
                      ملء الشاشة <ArrowLeft className="size-3" />
                    </button>
                  </div>
                }
              />
              <PreviewPanel
                tab={tab}
                setTab={setTab}
                dance={dance}
                setDance={setDanceId}
                carAnim={carAnim}
                setCarAnim={setCarAnimId}
                playing={playing}
                setPlaying={setPlaying}
                speed={speed}
                setSpeed={setSpeed}
                accent={accent}
                setAccent={setAccent}
                toggles={toggles}
                setToggle={setToggle}
                keybind={keybind}
                setKeybind={setKeybind}
                onExpand={() => setModalOpen(true)}
              />

              {/* feature strip */}
              <div className="mt-3 grid gap-2 sm:grid-cols-3">
                {features.map((f) => (
                  <div
                    key={f.title}
                    className="glass-soft group flex items-start gap-2.5 rounded-xl px-3 py-2.5 transition-colors hover:border-[rgb(var(--accent-rgb)/0.25)]"
                  >
                    <span className="grid size-7 shrink-0 place-items-center rounded-lg accent-soft-bg transition-transform group-hover:scale-105">
                      <f.icon className="size-3.5 accent-text" />
                    </span>
                    <div className="min-w-0">
                      <p className="text-[11.5px] font-semibold text-white/80">{f.title}</p>
                      <p className="mt-0.5 text-[9.5px] leading-4 text-white/30">{f.desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </section>

            <DanceGrid
              activeId={danceId}
              playing={playing}
              onPlay={handlePlayDance}
              setPlaying={setPlaying}
            />

            <CarSection
              carAnim={carAnim}
              setCarAnim={setCarAnimId}
              playing={playing}
              setPlaying={setPlaying}
              speed={speed}
              setSpeed={setSpeed}
              accent={accent}
            />

            <ScriptSection
              notify={notify}
              onDownloadFile={handleDownloadFile}
              onDownloadBundle={handleDownloadBundle}
            />

            <SettingsSection
              accent={accent}
              setAccent={setAccent}
              speed={speed}
              setSpeed={setSpeed}
              toggles={toggles}
              setToggle={setToggle}
              keybind={keybind}
              setKeybind={setKeybind}
              playing={playing}
              setPlaying={setPlaying}
              onReset={handleReset}
              notify={notify}
            />

            <div className="space-y-4 pt-2">
              <Ornament />
              <div className="flex flex-col items-center justify-between gap-3 rounded-2xl border border-white/[0.06] bg-white/[0.02] px-4 py-3 sm:flex-row">
                <p className="flex items-center gap-2 text-[10.5px] text-white/35">
                  <ShieldCheck className="size-3.5 text-emerald-400/80" />
                  حزمة تجميلية 100% — بدون Aim Silent أو أي أدوات غش.
                </p>
                <button
                  onClick={handleDownloadBundle}
                  className="btn-gold flex items-center gap-1.5 rounded-lg px-3 py-2 text-[11px] font-bold"
                >
                  تحميل الحزمة <ArrowLeft className="size-3" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </main>

      <Footer onDownload={handleDownloadBundle} />

      <PreviewModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        dance={dance}
        playing={playing}
        setPlaying={setPlaying}
        speed={speed}
        setSpeed={setSpeed}
        accent={accent}
        carAnim={carAnim}
      />

      <Toasts items={toasts} onDismiss={(id) => setToasts((prev) => prev.filter((t) => t.id !== id))} />
    </div>
  );
}
