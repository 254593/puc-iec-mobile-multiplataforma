// src/components/UpdatePrompt.tsx
// ✅ AVALIATIVO — TODO 3 (parte 2)
//
// O app já renderiza <UpdatePrompt /> em App.tsx. Seu trabalho é fazer ele funcionar.
//
// Use o hook do vite-plugin-pwa:
//   import { useRegisterSW } from 'virtual:pwa-register/react';
//
// Ele devolve dois estados (cada um é um par [valor, setter]) e uma função:
//   - offlineReady  → true quando o app terminou de ser cacheado ("já funciona offline")
//   - needRefresh   → true quando existe uma NOVA versão esperando (SW em "waiting")
//   - updateServiceWorker(true) → ativa a nova versão e recarrega a página
//
// O que o componente deve mostrar:
//   1. offlineReady  → aviso "App pronto para uso offline" + botão para dispensar (setOfflineReady(false))
//   2. needRefresh   → aviso "Nova versão disponível" + botão "Atualizar" (updateServiceWorker(true))
//                      + botão "Depois" que dispensa o aviso (setNeedRefresh(false))
//   3. nenhum dos dois → não renderiza nada (return null)
//
// ⚠️ Só funciona com registerType: 'prompt' (TODO 3, parte 1) e no BUILD (npm run build && npm run preview).

import { useRegisterSW } from 'virtual:pwa-register/react';

const toastStyle: React.CSSProperties = {
  position: 'fixed',
  left: 16,
  right: 16,
  bottom: 84, // acima da BottomTabBar
  zIndex: 1000,
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'space-between',
  gap: 12,
  maxWidth: 560,
  margin: '0 auto',
  padding: '12px 16px',
  background: '#1c3a52',
  color: '#e5e5e5',
  border: '1px solid #01b4e4',
  borderRadius: 12,
  boxShadow: '0 6px 20px rgba(0,0,0,.4)',
  fontSize: 14,
};

const primaryBtn: React.CSSProperties = {
  background: '#01b4e4',
  color: '#0d253f',
  border: 'none',
  borderRadius: 6,
  padding: '6px 14px',
  fontWeight: 700,
  cursor: 'pointer',
  fontSize: 13,
};

const ghostBtn: React.CSSProperties = {
  ...primaryBtn,
  background: 'transparent',
  color: '#90cae4',
  border: '1px solid #2a3f55',
};

export function UpdatePrompt() {
  const {
    offlineReady: [offlineReady, setOfflineReady],
    needRefresh: [needRefresh, setNeedRefresh],
    updateServiceWorker,
  } = useRegisterSW();

  // nova versão tem prioridade: o SW novo está em "waiting" e só assume com o aceite do usuário
  if (needRefresh) {
    return (
      <div role="alert" style={toastStyle}>
        <span>🔄 Nova versão disponível</span>
        <span style={{ display: 'flex', gap: 8 }}>
          <button style={primaryBtn} onClick={() => updateServiceWorker(true)}>
            Atualizar
          </button>
          <button style={ghostBtn} onClick={() => setNeedRefresh(false)}>
            Depois
          </button>
        </span>
      </div>
    );
  }

  if (offlineReady) {
    return (
      <div role="status" style={toastStyle}>
        <span>✅ App pronto para uso offline</span>
        <button style={ghostBtn} onClick={() => setOfflineReady(false)}>
          OK
        </button>
      </div>
    );
  }

  return null;
}
