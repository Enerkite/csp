import ControlInterface from 'clock-common/lib/Tools/ControlInterface';
import { useContext, useState } from 'react';
import LoadDynamicComponents from 'clock-common/lib/Components/Dynamic/LoadDynamicComponents';
import {
  KeyValueSetRadio,
  PluginConfigContext,
  useKeyValueSetSymbol
} from '@mplab_harmony/harmony-plugin-client-lib';
import {
  getDynamicLabelsFromJSON,
  getDynamicSymbolsFromJSON
} from 'clock-common/lib/Tools/ClockJSONTools';
import LoadDynamicFreqencyLabels from 'clock-common/lib/Components/Dynamic/LoadDynamicFreqencyLabels';
import { removeDuplicates } from 'clock-common/lib/Tools/Tools';
import ResetSymbolsIcon from 'clock-common/lib/Components/ResetSymbolsIcon';
import SettingsDialog from 'clock-common/lib/Components/SettingsDialog';

let oschfSettingsSymbol = [
  'OSCHF_OSCHFCTRL_FRQSEL',
  'OSCHF_OSCHFCTRL_ONDEMAND',
  'OSCHF_OSCHFCTRL_AUTOTUNE',
];

const OscillatorsControllerBox = (props: {
  oscillatorData: ControlInterface[];
  cx: (...classNames: string[]) => string;
}) => {
  const { componentId = 'core' } = useContext(PluginConfigContext);
 let symbols: any = props.oscillatorData.map((e) => e.symbol_id).filter((e) => e !== undefined);
  symbols = symbols.concat(
    oschfSettingsSymbol,
  );
  symbols = removeDuplicates(symbols);


  const [dynamicSymbolsInfo] = useState(() => getDynamicSymbolsFromJSON(props.oscillatorData));
  const [dynamicLabelSymbolInfo] = useState(() => getDynamicLabelsFromJSON(props.oscillatorData));

  return (
    <div>
      <LoadDynamicComponents
        componentId={componentId}
        dynamicSymbolsInfo={dynamicSymbolsInfo}
        cx={props.cx}
      />
      <LoadDynamicFreqencyLabels
        componentId={componentId}
        dynamicLabelSymbolsInfo={dynamicLabelSymbolInfo}
        cx={props.cx}
      />
     

      <SettingsDialog
        tooltip='OSCHF Configuration'
        componentId={componentId}
        className={props.cx('internalOsc48Settings')}
        symbolArray={oschfSettingsSymbol}
        dialogWidth='50rem'
        dialogHeight='30rem'
      />
      <ResetSymbolsIcon
        tooltip='Reset Oscillator symbols to default value'
        className={props.cx('oscillatorsControllerReset')}
        componentId={componentId}
        resetSymbolsArray={symbols}
      />
    </div>
  );
};
export default OscillatorsControllerBox;