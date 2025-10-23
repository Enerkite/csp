import $ from 'jquery';

export async function initializeSVG(svgId : string, svgSizeCss: string,cx: (...classNames: string[]) => string) {
  $('#'+svgId+'').addClass(cx(svgSizeCss));
}

export async function updateSVG(hideShape: boolean, svgShpaeId: string) {
  const sharedPin = $('#'+svgShpaeId+'');
  if (hideShape) {
    sharedPin.css('opacity', '-1');
  } else {
    sharedPin.css('opacity', '1');
  }
}
