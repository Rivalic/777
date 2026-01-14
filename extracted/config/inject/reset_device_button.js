// Reset Device ID Button Injection Script
// Adds a button to web views for resetting device ID

(function() {
    'use strict';
    
    const BUTTON_ID = 'device-id-reset-button';
    const BUTTON_STYLE = `
        position: fixed;
        bottom: 100px;
        right: 20px;
        z-index: 9999;
        padding: 12px 24px;
        background: linear-gradient(135deg, #FF6B35 0%, #F7931E 100%);
        color: white;
        border: none;
        border-radius: 25px;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(255, 107, 53, 0.4);
        transition: all 0.3s ease;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    `;
    
    const HOVER_STYLE = `
        transform: scale(1.05);
        box-shadow: 0 6px 16px rgba(255, 107, 53, 0.6);
    `;
    
    function createResetButton() {
        // Check if button already exists
        if (document.getElementById(BUTTON_ID)) {
            return;
        }
        
        const button = document.createElement('button');
        button.id = BUTTON_ID;
        button.textContent = '🔄 Reset Device ID';
        button.style.cssText = BUTTON_STYLE;
        
        // Add hover effect
        button.addEventListener('mouseenter', function() {
            this.style.cssText = BUTTON_STYLE + HOVER_STYLE;
        });
        
        button.addEventListener('mouseleave', function() {
            this.style.cssText = BUTTON_STYLE;
        });
        
        // Click handler
        button.addEventListener('click', function() {
            handleResetClick();
        });
        
        // Add to body
        document.body.appendChild(button);
        
        // Make sure it stays on top
        setInterval(function() {
            if (button.parentNode !== document.body) {
                document.body.appendChild(button);
            }
            button.style.zIndex = '9999';
        }, 1000);
    }
    
    function handleResetClick() {
        // Try native method first
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.deviceIDRotator) {
            window.webkit.messageHandlers.deviceIDRotator.postMessage({
                action: 'rotate',
                callback: 'deviceIDRotated'
            });
            showNotification('Resetting device ID...', 'info');
            return;
        }
        
        // Fallback: Show alert with instructions
        const currentID = localStorage.getItem('deviceID') || 'Not set';
        const confirmed = confirm(
            'Reset Device ID?\n\n' +
            'Current ID: ' + currentID.substring(0, 8) + '...\n\n' +
            'This will generate a new device identifier.\n' +
            'Please use the native app settings if available.'
        );
        
        if (confirmed) {
            // Generate new ID
            const newID = generateUUID();
            localStorage.setItem('deviceID', newID);
            localStorage.setItem('deviceIDResetTime', new Date().toISOString());
            
            showNotification('Device ID reset! New ID: ' + newID.substring(0, 8) + '...', 'success');
            
            // Reload page after delay
            setTimeout(function() {
                if (confirm('Reload page to apply changes?')) {
                    location.reload();
                }
            }, 2000);
        }
    }
    
    function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
    
    function showNotification(message, type) {
        // Remove existing notification
        const existing = document.getElementById('device-id-notification');
        if (existing) {
            existing.remove();
        }
        
        const notification = document.createElement('div');
        notification.id = 'device-id-notification';
        notification.textContent = message;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 10000;
            padding: 12px 24px;
            background: ${type === 'success' ? '#4CAF50' : '#2196F3'};
            color: white;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            animation: slideDown 0.3s ease;
        `;
        
        // Add animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideDown {
                from {
                    opacity: 0;
                    transform: translateX(-50%) translateY(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateX(-50%) translateY(0);
                }
            }
        `;
        document.head.appendChild(style);
        
        document.body.appendChild(notification);
        
        // Auto remove after 3 seconds
        setTimeout(function() {
            notification.style.animation = 'slideDown 0.3s ease reverse';
            setTimeout(function() {
                notification.remove();
            }, 300);
        }, 3000);
    }
    
    // Callback for native method
    window.deviceIDRotated = function(newID) {
        showNotification('Device ID reset successfully!', 'success');
        setTimeout(function() {
            if (confirm('Restart app to apply changes?')) {
                // Try to close app or reload
                if (window.location) {
                    window.location.href = 'swiggy://restart';
                }
            }
        }, 2000);
    };
    
    // Initialize button when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(createResetButton, 500);
        });
    } else {
        setTimeout(createResetButton, 500);
    }
    
    // Also try after page load
    window.addEventListener('load', function() {
        setTimeout(createResetButton, 1000);
    });
    
    // Retry periodically for dynamic content
    setInterval(function() {
        if (!document.getElementById(BUTTON_ID)) {
            createResetButton();
        }
    }, 2000);
    
    console.log('[DeviceIDRotator] Reset button injection script loaded');
})();
