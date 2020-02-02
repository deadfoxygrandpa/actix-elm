const purgeElm = (content) => {
	// find everything passed to class functions and split the string
	var re = /class\s+"([^"]+)"/g;
	var found = [...content.matchAll(re)];

	var classes = Array.from([...new Set(found
		.flatMap(x => x[1].split(" "))
		.map(s => s.trim())
		.filter(s => s.length > 0))]);
	return classes;
};

module.exports = {
  content: ['frontend/**/*.elm'],
  css: ['static/style.css'],
  extractors: [
  	{
  		extractor: purgeElm,
  		extensions: ['elm']
  	}
  ]
}