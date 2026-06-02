import { ReactComponent as ClockPIC32CMPL10 } from '../Resources/data/react_PIC32CM_PL.svg';
import positions from '../Resources/data/positions.module.css';
import styles from './block-diagram-view.module.css';
import tabCss from '../Styles/tab.module.css';
import ClockPic32cmpl10 from '../Resources/data/controls.json';
import { useEffect, useState } from 'react';
import { ConfirmDialog } from 'primereact/confirmdialog';
import Oscillators32KHzControllerBox from './ClockBox/Oscillators32KHzControllerBox';
import RTCClockController from './ClockBox/RTCClockController';
import MainClockController from './ClockBox/MainClockController';
import { MenuItem } from 'primereact/menuitem';
import {
  createClassResolver,
  PluginToolbar,
  usePannableContainer,
  useZoomableContainer
} from '@mplab_harmony/harmony-plugin-client-lib';
import ControlInterface from 'clock-common/lib/Tools/ControlInterface';
import useWindowDimensions from './Tools/WindowSize';
import Gclk0ControllerBox from './ClockBox/GCLK/Gclk0ControllerBox';
import Gclk1ControllerBox from './ClockBox/GCLK/Gclk1ControllerBox';
import GclkXControllerBox from './ClockBox/GCLK/GclkXControllerBox';
import PeripheralClockControllerBox from './ClockBox/PopUp/PeripheralClockControllerBox';
import { initializeSVG } from './Tools/SVGhandler';
import OscillatorsControllerBox from './ClockBox/OscillatorControllerBox';

let svgId = 'clk_pic32cmpl10-main-image';

export let controlJsonData =  ClockPic32cmpl10 as ControlInterface[];
export const cx = createClassResolver(positions, styles, tabCss);
const MainBlock = () => {
  const [summaryDialogVisible, setSummaryDialogVisible] = useState(false);

  const zoomableContainer = useZoomableContainer();
  const pannableContainer = usePannableContainer();

  const { height, width } = useWindowDimensions();

  useEffect(() => {
    console.log(height, width);
  }, [height, width]);
  useEffect(() => {
    initializeSVG(svgId,'main-block-diagram',cx);
  }, []);

  const items: MenuItem[] = [
    // {
    //   label: 'Summary',
    //   icon: 'pi pi-fw pi-chart-bar',
    //   command: () => setSummaryDialogVisible(true)
    // },
    {
      label: 'Zoom',
      icon: 'pi pi-search-plus',
      items: [
        {
          label: 'Zoom In (Alt + Scroll Up)',
          icon: 'pi pi-fw pi-search-plus',
          command: () => zoomableContainer.zoomIn()
        },
        {
          label: 'Reset Zoom (Alt + Scroll Click)',
          icon: 'pi pi-fw pi-refresh',
          command: () => zoomableContainer.resetZoom()
        },
        {
          label: 'Zoom Out (Alt + Scroll Down)',
          icon: 'pi pi-fw pi-search-minus',
          command: () => zoomableContainer.zoomOut()
        }
      ]
    }
  ];

  function getBoxControlData(boxId: string) {
    return controlJsonData.filter((e) => e.box_id === boxId);
  }

  try {
    return (
      <>
        <ConfirmDialog />
        <PluginToolbar
          menuItems={items}
          title='Clock Configurator'
        />
        <div
          className={cx('pannable-container')}
          ref={pannableContainer.ref}
          {...pannableContainer.props}>
          <div
            className={cx('svg-container')}
            ref={zoomableContainer.ref}
            {...zoomableContainer.props}>
            <ClockPIC32CMPL10 id={svgId}></ClockPIC32CMPL10>
           <OscillatorsControllerBox
              oscillatorData={getBoxControlData('oscillatorsControllerBox')}
              cx={cx}
            />
            <Oscillators32KHzControllerBox
              oscillatorData={getBoxControlData('oScillators32KhzController')}
              cx={cx}
            />
            <Gclk0ControllerBox
              gclk0Controller={getBoxControlData('gclkGen0Box')}
              cx={cx}
            />
            <Gclk1ControllerBox
              gclk1Controller={getBoxControlData('gclkGen1Box')}
              cx={cx}
            />
            <GclkXControllerBox
              controller={getBoxControlData('gclkGenXBox')}
              cx={cx}
            />
            <MainClockController
              mainClockController={getBoxControlData('mainClockBox')}
              cx={cx}
            />
            <RTCClockController
              rtcClockController={getBoxControlData('rtcClockSelBox')}
              cx={cx}
            />
            <PeripheralClockControllerBox cx={cx} />

            {/* <CustomLogic cx={cx} /> */}
          </div>
        </div>
      </>
    );
  } catch (error) {
    console.log(error);
    return <>Error Occurred! </>;
  }
};
export default MainBlock;
