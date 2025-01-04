import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chart"
// https://github.com/ankane/chartkick?tab=readme-ov-file#javascript-api
// TODO: https://stackoverflow.com/questions/912596/how-to-turn-a-string-into-a-javascript-function-call
export default class extends Controller {
  connect() {
    console.log("=== CHART CONTROLLER CONNECTED ===")
    // var chartElement = document.getElementById("by_referrer");
    // this.registerClickHandler(chartElement);
    var chart = Chartkick.charts["by_referrer"];
    chart.options.onClick = function(event) {
      console.log("=== CHART WAS CLICKED ===")
      console.dir(event)
    }
    chart.options.library.onClick = function(event) {
      console.log("=== CHART WAS CLICKED ===")
      console.dir(event)
    }
    console.dir(chart)
  }

  // No good because need to get onClick inside of chart.js
  // https://www.chartjs.org/docs/latest/configuration/interactions.html#converting-events-to-data-values
  // registerClickHandler(chartElement) {
    // chartElement.addEventListener("click", function(event) {
    //   console.log("=== CHART WAS CLICKED ===")
    //   var chart = Chartkick.charts["by_referrer"];
    //   console.dir(chart);
    //   console.dir(event)
    //   const canvasPosition = Chart.helpers.getRelativePosition(event, chart);
    // });
  // }
}
