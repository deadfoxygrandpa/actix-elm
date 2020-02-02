module.exports = {
  content: ['static/elm.js'],
  css: ['static/style.css'],
  defaultExtractor: content => content.match(/[\w-/:]*[\w-/:]/g) || []
}