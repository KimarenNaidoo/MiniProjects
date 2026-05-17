

function togglePasswordVisibility() {
    let passwordInput = document.getElementById("password-input");
    let toggleButton = document.getElementById("showPassword");

    if (toggleButton.checked && passwordInput.type === "password") {
        passwordInput.type = "text";
    }
    else {
        passwordInput.type = "password";
    }
}

function validatePassword() {
    let passwordInput = document.getElementById("password-input");
    let password = passwordInput.value;
    
    if (password.length === 0) {
        alert("Please enter a password.");
        return false;
    }
    return true;
}