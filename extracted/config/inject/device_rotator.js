// Device ID Rotator Injection Script
(function() {
    function addRotatorButton() {
        const button = document.createElement('button');
        button.textContent = '🔄 Rotate Device ID';
        button.style.cssText = 'padding: 12px 24px; background: #FF6B35; color: white; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; margin: 20px; font-weight: bold;';
        button.onclick = function() {
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.deviceIDRotator) {
                window.webkit.messageHandlers.deviceIDRotator.postMessage({action: 'rotate'});
            } else {
                alert('Device ID rotation requires native app support. Please use the native settings.');
            }
        };
        
        const settingsContainer = document.querySelector('.settings-container') || 
                                  document.querySelector('[class*="Settings"]') ||
                                  document.querySelector('body');
        if (settingsContainer) {
            const existingButton = settingsContainer.querySelector('[data-device-rotator]');
            if (!existingButton) {
                button.setAttribute('data-device-rotator', 'true');
                settingsContainer.insertBefore(button, settingsContainer.firstChild);
            }
        }
    }
    
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', addRotatorButton);
    } else {
        addRotatorButton();
    }
    
    setTimeout(addRotatorButton, 1000);
    setTimeout(addRotatorButton, 3000);
})();
