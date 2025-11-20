class Validator {
  // Static method to validate email and return a message
  static String? validateEmail(String email) {
    // Regular expression for email validation
    const emailRegex = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';

    // Validate email and return appropriate message
    if (email.isEmpty) {
      return "Email cannot be empty";
    } else if (!RegExp(emailRegex).hasMatch(email)) {
      return "Invalid email format";
    }
    return null;
  }

  static String? validateMobileOrEmail(String input) {
    const emailRegex = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';

    const mobileRegex = r'^[0-9]{10}$';

    if (input.isEmpty) {
      return "Input cannot be empty";
    }

    if (RegExp(mobileRegex).hasMatch(input)) {
      return null; // Mobile number is valid
    }

    if (RegExp(emailRegex).hasMatch(input)) {
      return null; // Email is valid
    }

    return "Invalid format. Please enter a valid mobile number or email.";
  }

  static String? validatePassword(String password) {
    // Minimum password length required by Firebase
    const int minPasswordLength = 6;

    if (password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < minPasswordLength) {
      return "Password must be at least $minPasswordLength characters long";
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain at least one uppercase letter";
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "Password must contain at least one lowercase letter";
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Password must contain at least one number";
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return "Password must contain at least one special character";
    }
    return null;
  }

  static String? validateSimplePassword(String password) {
    // Minimum password length
    const int minPasswordLength = 8;

    if (password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < minPasswordLength) {
      return "Password must be at least $minPasswordLength characters long";
    }
    return null; // Password is valid
  }

  static String? validateName(String name) {
    // Regular expression to allow only alphabets and spaces
    if (name.isEmpty) {
      return "Name cannot be empty";
    } else if (name.length < 3) {
      return "Name must be at least 3 characters long";
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return "Name must contain only alphabets and spaces";
    }
    return null;
  }

  static String? validateMobileNumber(String mobileNumber) {
    if (mobileNumber.isEmpty) {
      return "Mobile number cannot be empty";
    } else if (mobileNumber.length != 10) {
      return "Mobile number must be exactly 10 digits";
    } else if (!RegExp(r'^\d{10}$').hasMatch(mobileNumber)) {
      return "Mobile number must contain only digits";
    }

    return null;
  }

  static String? validateAboutUs(String aboutUs) {
    if (aboutUs.isEmpty) {
      return "About Us cannot be empty";
    }
    return null;
  }

  static String? validateAddress(String aboutUs) {
    if (aboutUs.isEmpty) {
      return "Address cannot be empty";
    }
    return null;
  }
}
