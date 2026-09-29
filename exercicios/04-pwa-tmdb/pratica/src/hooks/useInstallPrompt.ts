// src/hooks/useInstallPrompt.ts

import { useState, useEffect } from 'react';

type BeforeInstallPromptEvent = Event & {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>;
};

// ── TODO 5 ─────────────────────────────────────────────────────────────────
// Capture o evento `beforeinstallprompt` para mostrar um botão "Instalar"
// customizado em vez do banner padrão do browser.
//
// Passos:
// 1. Ouça window.addEventListener('beforeinstallprompt', handler)
//    e chame event.preventDefault() — isso suprime o banner automático
// 2. Salve o evento em estado (setDeferred)
// 3. Ao chamar triggerInstall(), chame deferred.prompt() e aguarde userChoice
// 4. Se outcome === 'accepted', limpe o deferred (botão some)
// 5. Limpe o listener no cleanup do useEffect
//
// Nota: iOS Safari não dispara beforeinstallprompt.
//       O hook retorna deferred=null nesses casos — botão não aparece. OK.
// ───────────────────────────────────────────────────────────────────────────

export function useInstallPrompt() {
  const [deferred, setDeferred] = useState<BeforeInstallPromptEvent | null>(null);

  useEffect(() => {
    // TODO 5: implemente aqui
    const handler = (e: Event) => {
      e.preventDefault();
      setDeferred(e as BeforeInstallPromptEvent);
    };
    window.addEventListener('beforeinstallprompt', handler);
    return () => window.removeEventListener('beforeinstallprompt', handler);
  }, []);

  const triggerInstall = async () => {
    // TODO 5: chame deferred.prompt() e trate userChoice
    if (!deferred) return;
    await deferred.prompt();
    const { outcome } = await deferred.userChoice;
    if (outcome === 'accepted') setDeferred(null);
  };

  const isIOS = /iphone|ipad|ipod/i.test(navigator.userAgent);
  const isMobile = /iphone|ipad|ipod|android/i.test(navigator.userAgent);
  const isDesktop = !isMobile; // Chrome/Edge desktop também dispara beforeinstallprompt
  const isStandalone =
    window.matchMedia('(display-mode: standalone)').matches ||
    (navigator as any).standalone === true;

  return { canInstall: !!deferred, triggerInstall, isIOS, isDesktop, isStandalone };
}
