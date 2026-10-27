// src/hooks/useOfflineStatus.ts
// ✅ AVALIATIVO — TODO 5
//
// Implemente este hook pra rastrear o status de conexão do browser.
//
// O que fazer:
//   1. useState com valor inicial = navigator.onLine  (true = online)
//   2. useEffect: adicione dois listeners em window:
//        window.addEventListener('online',  () => setIsOnline(true))
//        window.addEventListener('offline', () => setIsOnline(false))
//      Retorne uma função de cleanup que remove esses listeners.
//   3. Retorne { isOnline }
//
// Como testar manualmente:
//   DevTools → Network → Throttling → "Offline"
//   O banner "📡 Offline — exibindo dados do cache" deve aparecer na aba Favoritos.

import { useState, useEffect } from 'react';

export function useOfflineStatus(): { isOnline: boolean } {
  const [isOnline, setIsOnline] = useState(() => navigator.onLine);

  useEffect(() => {
    const goOnline = () => setIsOnline(true);
    const goOffline = () => setIsOnline(false);
    window.addEventListener('online', goOnline);
    window.addEventListener('offline', goOffline);
    // cleanup: sem isso cada montagem deixaria listeners "órfãos" apontando pra um componente morto
    return () => {
      window.removeEventListener('online', goOnline);
      window.removeEventListener('offline', goOffline);
    };
  }, []);

  return { isOnline };
}
