import {
  useIntegerSymbol,
  useBooleanSymbol,
  useKeyValueSetSymbol,
  PluginConfigContext,
  useCommentSymbol,
  useComboSymbol
} from '@mplab_harmony/harmony-plugin-client-lib';
import { createContext, useContext, useEffect, useState } from 'react';

function getSuffixDigitsAsNumber(value: string) {
  if (value === undefined) {
    return 69696;
  }
  const matches = value.match(/(\d+)$/);
  if (matches) {
    return parseInt(matches[1], 10);
  }
  return 69696;
}

const useBlockDiagramViewModel = () => {
  const { componentId = 'adc' } = useContext(PluginConfigContext);

  // const salveEnable = useBooleanSymbol({ componentId, symbolId: 'ADC_CTRLA_SLAVEEN' });

  const startEventInput = useKeyValueSetSymbol({ componentId, symbolId: 'ADC_EVCTRL_START' });
  const conversionTrigger = useComboSymbol({ componentId, symbolId: 'ADC_CONV_TRIGGER' });
  // const flushEventInput = useKeyValueSetSymbol({ componentId, symbolId: 'ADC_EVCTRL_FLUSH' });
  // const enableUserSequenceMode = useBooleanSymbol({ componentId, symbolId: 'ADC_SEQ_ENABLE' });
  const enableRunInStandby = useBooleanSymbol({ componentId, symbolId: 'ADC_CTRLA_RUNSTDBY' });
  const enableOnDemandControl = useBooleanSymbol({ componentId, symbolId: 'ADC_CTRLA_ONDEMAND' });

  const prescaler = useKeyValueSetSymbol({ componentId, symbolId: 'ADC_CTRLB_PRESCALER' });
  const [prescalerValue, setPrescalerValue] = useState(0);

  const resultResolution = useKeyValueSetSymbol({ componentId, symbolId: 'ADC_CTRLD_RESOLUTION' });
  const positiveInputCombo = useKeyValueSetSymbol({
    componentId,
    symbolId: 'ADC_INPUTCTRL_MUXPOS'
  });
  const negativeInputCombo = useKeyValueSetSymbol({
    componentId,
    symbolId: 'ADC_INPUTCTRL_MUXNEG'
  });

  const accumulatedSampelsCombo = useKeyValueSetSymbol({
    componentId,
    symbolId: 'ADC_CTRLD_SAMPNUM'
  });
  // const rightShiftsNumbers = useIntegerSymbol({ componentId, symbolId: 'ADC_AVGCTRL_ADJRES' });
  const sampleLength = useIntegerSymbol({ componentId, symbolId: 'ADC_CTRLE_SAMPLEN' });
  const referenceCombo = useKeyValueSetSymbol({
    componentId,
    symbolId: 'ADC_CTRLC_REFSEL'
  });
  const convTime = useCommentSymbol({ componentId, symbolId: 'ADC_CTRLE_SAMPLEN_TIME' });
  const [convTimeValue, setConvTimeValue] = useState('');

  const highThresholdSpinner = useIntegerSymbol({ componentId, symbolId: 'ADC_WINHT' });
  const lowThresholdSpinner = useIntegerSymbol({ componentId, symbolId: 'ADC_WINLT' });
  const comparsionModeCombo = useKeyValueSetSymbol({
    componentId,
    symbolId: 'ADC_WINCTRL_WINMODE'
  });

  const enableWinmonInterrupt = useBooleanSymbol({ componentId, symbolId: 'ADC_INTENSET_WCMP' });
  const enableWinmonEvenOut = useBooleanSymbol({
    componentId,
    symbolId: 'ADC_WINDOW_OUTPUT_EVENT'
  });

  // const enableleft_alignedResult = useBooleanSymbol({ componentId, symbolId: 'ADC_CTRLC_LEFTADJ' });
  const enableResultInterrupt = useBooleanSymbol({ componentId, symbolId: 'ADC_INTENSET_RESRDY' });
  const enableResultIEvent = useBooleanSymbol({ componentId, symbolId: 'ADC_EVCTRL_RESRDYEO' });
  const enableSampleInterrupt = useBooleanSymbol({ componentId, symbolId: 'ADC_INTENSET_SAMPRDY' });
  const enableSampleIEvent = useBooleanSymbol({ componentId, symbolId: 'ADC_EVCTRL_SAMPRDYEO' });
  const enableFliter = useBooleanSymbol({ componentId, symbolId: 'ADC_CTRLD_FILTER' });
  const enableChopping = useBooleanSymbol({ componentId, symbolId: 'ADC_CTRLD_CHOPPING' });
  const disableVoltagePump = useBooleanSymbol({ componentId, symbolId: 'ADC_CTRLD_VPD' });
  const operationMode = useKeyValueSetSymbol({
    componentId,
    symbolId: 'ADC_COMMAND_OPMODE'
  });
  const resultScaling = useKeyValueSetSymbol({
    componentId,
    symbolId: 'ADC_CTRLD_SCALING'
  });

  useEffect(() => {
    const temp = convTime.label.replace('**** Conversion Time is ', '').replace(' ****', '');
    setConvTimeValue(temp);
  }, [convTime.label]);

  useEffect(() => {
    setPrescalerValue(getSuffixDigitsAsNumber(prescaler.selectedOption));
  }, [prescaler.selectedOption]);

  return {
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
  };
};

export default useBlockDiagramViewModel;

export type BlockDiagramViewModel = ReturnType<typeof useBlockDiagramViewModel>;

export const BlockDiagramContext = createContext<BlockDiagramViewModel | null>(null);
