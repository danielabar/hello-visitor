// A first attempt at canvas accessibility
Chartkick.eachChart( (chart) => {
  console.dir(chart.getOptions())
  // console.dir(chart.getData())
  canvasEl = chart.getElement().querySelector('canvas');
  canvasEl.setAttribute('role', 'graphics-document'); // https://www.w3.org/TR/graphics-aria-1.0/
  canvasEl.setAttribute('aria-label', chart.getOptions().library.plugins.title.text);
})
