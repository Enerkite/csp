import adcSVG from '../images/react_adc_06272.svg';
import { Button } from 'primereact/button';
import positions from './positions.module.css';
import styles from './block-diagram-view.module.css';
import { useState } from 'react';
import { Dialog } from 'primereact/dialog';
import { Dropdown } from 'primereact/dropdown';
import ChannelSequence from './channel-sequence/ChannelSequence';
import {
  usePannableContainer,
  useZoomableContainer,
  CheckBox,
  DropDown,
  PluginToolbar,
  createClassResolver,
  InputNumber,
  ComboRadio
} from '@mplab_harmony/harmony-plugin-client-lib';
import { MenuItem } from 'primereact/menuitem';
import useBlockDiagramViewModel from './BlockDiagramViewModel';
import Summary from './summary/Summary';
interface RegisterOption {
  name: string; // The label displayed in the dropdown (Result, Sample)
  value: string; // The actual value stored when an item is selected (Result Register, Sample Register)
}

const cx = createClassResolver(positions, styles);

function BlockDiagramView() {
  const [channelSequenceDialogVisible, setChannelSequenceDialogVisible] = useState(false);

  const [summaryDialogVisible, setSummaryDialogVisible] = useState(false);

  const pannableContainer = usePannableContainer();
  const zoomableContainer = useZoomableContainer();
  const registerOptions: RegisterOption[] = [
    { value: 'Result', name: 'Result Register' },
    { value: 'Sample', name: 'Sample Register' }
  ];
  const [selectedRegister, setSelectedRegister] = useState<string>(registerOptions[0].value);

  const {
    resultScaling,
    operationMode,
    disableVoltagePump,
    enableChopping,
    enableFliter,
    startEventInput,
    conversionTrigger,
    enableRunInStandby,
    enableOnDemandControl,
    prescaler,
    prescalerValue,
    resultResolution,
    positiveInputCombo,
    negativeInputCombo,
    accumulatedSampelsCombo,
    sampleLength,
    referenceCombo,
    convTimeValue,
    highThresholdSpinner,
    lowThresholdSpinner,
    comparsionModeCombo,
    enableWinmonInterrupt,
    enableWinmonEvenOut,
    enableResultInterrupt,
    enableResultIEvent,
    enableSampleInterrupt,
    enableSampleIEvent
  } = useBlockDiagramViewModel();

  const items: MenuItem[] = [
    {
      label: 'Summary',
      icon: 'pi pi-fw pi-chart-bar',
      command: () => setSummaryDialogVisible(true)
    },
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

  return (
    <>
      <PluginToolbar
        menuItems={items}
        title='ADC Configurator'
      />
      <div className={cx('block-diagram-container')}>
        <div
          className={cx('pannable-container')}
          ref={pannableContainer.ref}
          {...pannableContainer.props}>
          <div
            className={cx('svg-container')}
            ref={zoomableContainer.ref}
            {...zoomableContainer.props}>
            <img
              src={adcSVG}
              alt='ADC Block Diagram'
              className={cx('main-block-diagram')}
              draggable={false}
            />
            <Dropdown
              value={selectedRegister}
              onChange={(e) => setSelectedRegister(e.value)}
              options={registerOptions}
              optionLabel='name'
              className={cx('enableleft_alignedResult')}
            />
            <label className={cx('aligneResultLabel')}>{selectedRegister} Register</label>
            <label className={cx('eventLabel')}>{selectedRegister} Event</label>
            <label className={cx('interuptLabel')}>{selectedRegister} Interrupt</label>
            <DropDown
              keyValueSetSymbolHook={startEventInput}
              className={cx('startEventInput')}
              hidden={false}
              disabled={!startEventInput.visible}
            />

            <ComboRadio
              comboSymbolHook={conversionTrigger}
              classPrefix={'conversionTrigger'}
              classResolver={cx}
              hidden={false}
              disabled={!conversionTrigger.visible}
            />
            <DropDown
              keyValueSetSymbolHook={operationMode}
              className={cx('operationMode')}
              hidden={false}
              disabled={!operationMode.visible}
            />

            <label className={cx('enableFliterLabel')}>Enable Filter</label>
            <label className={cx('enableChoppingLabel')}>Enable Chopping</label>

            <DropDown
              keyValueSetSymbolHook={resultScaling}
              className={cx('resultScaling')}
              hidden={false}
              disabled={selectedRegister === 'Sample'}
            />
            <CheckBox
              booleanSymbolHook={disableVoltagePump}
              className={cx('disableVoltagePump')}
            />
            <CheckBox
              booleanSymbolHook={enableChopping}
              className={cx('enableChopping')}
              disabled={
                !(
                  operationMode.selectedOptionPair?.key === 'SERIES' ||
                  operationMode.selectedOptionPair?.key === 'BURST'
                )
              }
              hidden={false}
            />
            <CheckBox
              booleanSymbolHook={enableFliter}
              className={cx('enableFliter')}
              disabled={
                !(
                  operationMode.selectedOptionPair?.key === 'SERIES' ||
                  operationMode.selectedOptionPair?.key === 'BURST'
                )
              }
              hidden={false}
            />

            <CheckBox
              booleanSymbolHook={enableRunInStandby}
              className={cx('enableRunInStandby')}
            />
            <CheckBox
              booleanSymbolHook={enableOnDemandControl}
              className={cx('enableOnDemandControl')}
            />
            <DropDown
              keyValueSetSymbolHook={positiveInputCombo}
              className={cx('positiveInputCombo')}
              hidden={false}
              disabled={!positiveInputCombo.visible}
            />
            <DropDown
              keyValueSetSymbolHook={negativeInputCombo}
              className={cx('negativeInputCombo')}
              hidden={false}
              disabled={!negativeInputCombo.visible}
            />
            <DropDown
              keyValueSetSymbolHook={resultResolution}
              className={cx('resultResolution')}
            />
            <InputNumber
              integerSymbolHook={sampleLength}
              className={cx('sampleLength')}
            />
            <DropDown
              keyValueSetSymbolHook={referenceCombo}
              className={cx('referenceCombo')}
            />
            <label className={cx('convTime')}>{convTimeValue}</label>
            <div className={cx('samplingContainer')}>
              <div className={cx('labeledControlContainer')}>
                <label>Accumulated Sampels</label>{' '}
                <DropDown
                  keyValueSetSymbolHook={accumulatedSampelsCombo}
                  hidden={false}
                  style={{ width: '100px' }}
                />
              </div>
            </div>
            <DropDown
              keyValueSetSymbolHook={comparsionModeCombo}
              className={cx('comparsionModeCombo')}
            />
            <InputNumber
              integerSymbolHook={highThresholdSpinner}
              className={cx('highThresholdSpinner')}
              hidden={false}
              disabled={!highThresholdSpinner.visible}
            />
            <InputNumber
              integerSymbolHook={lowThresholdSpinner}
              className={cx('lowThresholdSpinner')}
              hidden={false}
              disabled={!lowThresholdSpinner.visible}
            />

            <CheckBox
              booleanSymbolHook={enableWinmonInterrupt}
              className={cx('enableWinmonInterrupt')}
              hidden={false}
              disabled={!enableWinmonInterrupt.visible}
            />
            <CheckBox
              booleanSymbolHook={enableWinmonEvenOut}
              className={cx('enableWinmonEvenOut')}
              hidden={false}
              disabled={!enableWinmonEvenOut.visible}
            />
            <DropDown
              keyValueSetSymbolHook={prescaler}
              className={cx('prescaler')}
              hidden={false}
              disabled={!prescaler.visible}
            />
            <label className={cx('prescalerLabel')}>{prescalerValue}</label>
            {selectedRegister === 'Result'&&<><CheckBox
              booleanSymbolHook={enableResultInterrupt}
              className={cx('enableResultInterrupt')}
            />
            <CheckBox
              booleanSymbolHook={enableResultIEvent}
              className={cx('enableResultIEvent')}
            /></>}

            {selectedRegister === 'Sample'&&<><CheckBox
              booleanSymbolHook={enableSampleInterrupt}
              className={cx('enableResultInterrupt')}
            />
             
            <CheckBox
              booleanSymbolHook={enableSampleIEvent}
              className={cx('enableResultIEvent')}
            /></>}


            <Dialog
              header='ADC Configuration Summary'
              visible={summaryDialogVisible}
              maximizable={true}
              onHide={() => setSummaryDialogVisible(false)}>
              <Summary></Summary>
            </Dialog>
          </div>
        </div>
      </div>
    </>
  );
}

export default BlockDiagramView;
