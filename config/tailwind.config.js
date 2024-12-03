const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  darkMode: ["class"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Fira Sans", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        // Brand Colors - Direct Access
        lochmara: {
          50: "hsl(var(--lochmara-50))",
          100: "hsl(var(--lochmara-100))",
          200: "hsl(var(--lochmara-200))",
          300: "hsl(var(--lochmara-300))",
          400: "hsl(var(--lochmara-400))",
          500: "hsl(var(--lochmara-500))",
          600: "hsl(var(--lochmara-600))",
          700: "hsl(var(--lochmara-700))",
          800: "hsl(var(--lochmara-800))",
          900: "hsl(var(--lochmara-900))",
          950: "hsl(var(--lochmara-950))",
        },
        punch: {
          50: "hsl(var(--punch-50))",
          100: "hsl(var(--punch-100))",
          200: "hsl(var(--punch-200))",
          300: "hsl(var(--punch-300))",
          400: "hsl(var(--punch-400))",
          500: "hsl(var(--punch-500))",
          600: "hsl(var(--punch-600))",
          700: "hsl(var(--punch-700))",
          800: "hsl(var(--punch-800))",
          900: "hsl(var(--punch-900))",
          950: "hsl(var(--punch-950))",
        },
        bunker: {
          50: "hsl(var(--bunker-50))",
          100: "hsl(var(--bunker-100))",
          200: "hsl(var(--bunker-200))",
          300: "hsl(var(--bunker-300))",
          400: "hsl(var(--bunker-400))",
          500: "hsl(var(--bunker-500))",
          600: "hsl(var(--bunker-600))",
          700: "hsl(var(--bunker-700))",
          800: "hsl(var(--bunker-800))",
          900: "hsl(var(--bunker-900))",
          950: "hsl(var(--bunker-950))",
        },

        // Semantic Colors - Component Usage
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",

        // Layout Components
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },

        // Interactive Components
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
          muted: "hsl(var(--primary-muted))",
          hover: "hsl(var(--primary-hover))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
          muted: "hsl(var(--secondary-muted))",
          hover: "hsl(var(--secondary-hover))",
        },

        // UI States
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },

        // Feedback States
        success: {
          DEFAULT: "hsl(var(--success))",
          foreground: "hsl(var(--success-foreground))",
          muted: "hsl(var(--success-muted))",
        },
        warning: {
          DEFAULT: "hsl(var(--warning))",
          foreground: "hsl(var(--warning-foreground))",
          muted: "hsl(var(--warning-muted))",
        },
        error: {
          DEFAULT: "hsl(var(--error))",
          foreground: "hsl(var(--error-foreground))",
          muted: "hsl(var(--error-muted))",
        },
        info: {
          DEFAULT: "hsl(var(--info))",
          foreground: "hsl(var(--info-foreground))",
          muted: "hsl(var(--info-muted))",
        },

        // Form Elements
        input: {
          DEFAULT: "hsl(var(--input))",
          border: "hsl(var(--input-border))",
          placeholder: "hsl(var(--input-placeholder))",
          ring: "hsl(var(--input-ring))",
        },

        // Borders and Rings
        border: "hsl(var(--border))",
        ring: "hsl(var(--ring))",

        // Application-Specific
        spellbooks: {
          base: "hsl(var(--background))",
          sidebar: "hsl(var(--muted))",
          element: {
            DEFAULT: "hsl(var(--muted))",
            hover: "hsl(var(--muted-foreground))",
          },
          subject: {
            math: "hsl(var(--primary-muted))",
            science: "hsl(var(--secondary-muted))",
            english: "hsl(var(--accent-muted))",
            history: "hsl(var(--success-muted))",
            default: "hsl(var(--info-muted))",
          },
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
        "2xl": "24px",
      },
      maxWidth: {
        assignment: "1040px",
      },
      boxShadow: {
        header: "0 2px 4px rgba(0,0,0,0.1)",
        soft: "0 2px 4px rgba(0,0,0,0.05)",
        hover: "0 4px 6px rgba(0,0,0,0.07)",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
    require("@tailwindcss/aspect-ratio"),
  ],
};
