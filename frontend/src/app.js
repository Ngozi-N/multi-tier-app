document.getElementById('checkBackend').addEventListener('click', async () => {
    const backendStatusSpan = document.getElementById('backendStatus');
    const checkBackendButton = document.getElementById('checkBackend');

    // Set loading state
    backendStatusSpan.textContent = 'Checking...';
    backendStatusSpan.className = 'status-message loading'; // Add loading class
    checkBackendButton.disabled = true; // Disable button during check
    checkBackendButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Refreshing...'; // Add spinner

    try {
        // Assuming backend is accessible at /api/backend/health via ALB routing
        // If not, you might need to use the full backend ALB DNS name here for direct access
        const response = await fetch('/api/backend/health');
        const data = await response.json();

        if (response.ok && data.status === 'OK') {
            backendStatusSpan.textContent = `Connected! Status: ${data.status} (DB: ${data.database})`;
            backendStatusSpan.className = 'status-message ok'; // Add ok class
        } else {
            backendStatusSpan.textContent = `Error: ${data.message || 'Backend connection failed.'}`;
            backendStatusSpan.className = 'status-message error'; // Add error class
        }
    } catch (error) {
        console.error('Failed to connect to backend:', error);
        backendStatusSpan.textContent = 'Failed to connect to backend API.';
        backendStatusSpan.className = 'status-message error'; // Add error class
    } finally {
        checkBackendButton.disabled = false; // Re-enable button
        checkBackendButton.innerHTML = '<i class="fas fa-sync-alt"></i> Refresh Status'; // Restore button text
    }
});

// Initial check on load
document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('checkBackend').click();
});