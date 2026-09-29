// src/components/InstallButton.tsx
// Banner de instalação: Android/Chrome via beforeinstallprompt; iOS via instrução manual.

import { useInstallPrompt } from '../hooks/useInstallPrompt';

const bannerStyle: React.CSSProperties = {
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'space-between',
  gap: 12,
  padding: '10px 16px',
  background: '#01b4e4',
  color: '#0d253f',
  borderRadius: 10,
  marginBottom: 16,
  fontSize: 14,
  fontWeight: 600,
};

const iosBannerStyle: React.CSSProperties = {
  padding: '10px 16px',
  background: '#1c3a52',
  color: '#90cae4',
  borderRadius: 10,
  marginBottom: 16,
  fontSize: 13,
  lineHeight: 1.4,
};

const btnStyle: React.CSSProperties = {
  background: '#0d253f',
  color: '#01b4e4',
  border: 'none',
  borderRadius: 6,
  padding: '6px 14px',
  fontWeight: 700,
  cursor: 'pointer',
  fontSize: 13,
  whiteSpace: 'nowrap',
};

export function InstallButton() {
  const { canInstall, triggerInstall, isIOS, isDesktop, isStandalone } = useInstallPrompt();

  if (isStandalone) return null;

  if (canInstall) {
    return (
      <div style={bannerStyle}>
        <span>{isDesktop ? '💻 Instale o app' : '📲 Instale o app na tela inicial'}</span>
        <button onClick={triggerInstall} style={btnStyle}>Instalar</button>
      </div>
    );
  }

  if (isIOS) {
    return (
      <div style={iosBannerStyle}>
        📲 <strong>iOS:</strong> toque em <strong>Compartilhar</strong> →{' '}
        <strong>Adicionar à Tela de Início</strong>
      </div>
    );
  }

  return null;
}
