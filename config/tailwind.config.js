module.exports = {
  content: [
    "./app/views/**/*.{html,erb}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.{js,jsx,ts,tsx}",
    "./app/assets/tailwind/**/*.{css}"
  ],
  theme: {
    extend: {
      colors: {
        cinematico: {
          black: "#0A0A0F",
          gold: "#D4AF37",
          grey: "#6C757D",
          light: "#F2F2F2",
        }
      },
      fontFamily: {
        cinzel: ["Cinzel", "serif"],
        inter: ["Inter", "sans-serif"],
      },
    },
  },
  plugins: [],
}
