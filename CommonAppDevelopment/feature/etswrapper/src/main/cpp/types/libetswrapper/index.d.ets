import { UIContext } from "@kit.ArkUI";
import { picker } from "@kit.CoreFileKit";
import { StringArrayCbWrapper, CatchCbWrapper } from '../../../ets/wrapper/wrapper';

/**
 * 注册封装后的select与save方法，全局仅需调用一次
 */
export const registryDocumentViewPickerFn: (
  select: (
    uiContext: UIContext,
    options: picker.DocumentSelectOptions,
    thenWrapper: StringArrayCbWrapper,
    catchWrapper: CatchCbWrapper
  ) => void,
  save: (
    uiContext: UIContext,
    options: picker.DocumentSaveOptions,
    thenWrapper: StringArrayCbWrapper,
    catchWrapper: CatchCbWrapper
  ) => void
) => void;

/**
 * 注册uiAbility的id及其对应uiContext
 */
export const addUIContext: (abilityID: string, uiContext: UIContext) => void;

/**
 * 在uiAbility销毁之前，应当注销对应uiContext
 */
export const removeUIContext: (abilityID: string) => void;

/**
 * 设置当前活跃的abilityID
 */
export const setTopAbilityID: (abilityID: string) => void;

/**
 * 模拟发起调用
 */
export const mockDocumentViewPickerSelectJSThread: () => void;

export const mockDocumentViewPickerSelectPThread: () => void;