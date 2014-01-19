unit HSharp.Behaviour.Interfaces;

interface

uses
  System.Rtti;

type
  IBehaviour<T> = interface
    ['{F0D26FAA-04AE-4C7F-A77A-D2F896DB06B9}']
    function GetMethod: TRttiMethod;
    procedure SetMethod(const aMethod: TRttiMethod);
    property Method: TRttiMethod read GetMethod write SetMethod;
  end;

  IBehaviourExecuteMethod<T, M> = interface(IBehaviour<T>)
    ['{353D7E0E-669A-4FC5-BFA1-DF1F1FA1B542}']
    function GetMethodWillBeExecuted: M;
    property MethodWillBeExecuted: M read GetMethodWillBeExecuted;
  end;

  IBehaviourReturnValue<T> = interface(IBehaviour<T>)
    ['{353D7E0E-669A-4FC5-BFA1-DF1F1FA1B542}']
    function GetExpectedResult: TValue;
    property ExpectedResult: TValue read GetExpectedResult;
  end;


implementation

end.
