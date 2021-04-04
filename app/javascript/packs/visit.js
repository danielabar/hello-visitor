// A first attempt at canvas accessibility
Chartkick.eachChart( (chart) => {
  console.dir(chart.getOptions())
  // console.dir(chart.getData())
  canvasEl = chart.getElement().querySelector('canvas');
  canvasEl.setAttribute('role', 'graphics-document'); // https://www.w3.org/TR/graphics-aria-1.0/
  canvasEl.setAttribute('aria-label', chart.getOptions().library.plugins.title.text);

  // Experiment: Answer is yes, VoiceOver + Safari does read the fallback content
  // p = document.createElement('p')
  // t = document.createTextNode('Will Voiceover read this text?')
  // p.appendChild(t)
  // canvasEl.appendChild(p)
})
