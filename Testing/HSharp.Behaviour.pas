unit HSharp.Behaviour;

interface

uses
  System.Rtti,
  HSharp.Behaviour.Interfaces;

type
  TBaseBehaviour<T> = class abstract(TInterfacedObject, IBehaviour<T>)
  strict private
    FMethod: TRttiMethod;
  private
    function GetMethod: TRttiMethod;
    procedure SetMethod(const aMethod: TRttiMethod);
  public
    property Method: TRttiMethod read GetMethod write SetMethod;
  end;

  TBehaviourExecuteMethod<T, M> = class abstract(TBaseBehaviour<T>,
    IBehaviourExecuteMethod<T, M>)
  strict private
    FMethodWillBeExecuted: M;
  private
    function GetMethodWillBeExecuted: M;
  public
    constructor Create(aMethodWillBeExecuted: M); reintroduce;
    property MethodWillBeExecuted: M read GetMethodWillBeExecuted;
  end;

  TBehaviourExecuteInterfaceMethod<T> = class(TBehaviourExecuteMethod<T,
    TVirtualInterfaceInvokeEvent>);

  TBehaviourExecuteObjectMethod<T> = class(TBehaviourExecuteMethod<T,
    TInterceptBeforeNotify>);

  TBehaviourReturnValue<T> = class(TBaseBehaviour<T>, IBehaviourReturnValue<T>)
  strict private
    FExpectedResult: TValue;
  private
    function GetExpectedResult: TValue;
  public
    constructor Create(aExpectedResult: TValue); reintroduce;
    property ExpectedResult: TValue read GetExpectedResult;
  end;

implementation

{ TBaseBehaviour<T> }

function TBaseBehaviour<T>.GetMethod: TRttiMethod;
begin
  Result := FMethod;
end;

procedure TBaseBehaviour<T>.SetMethod(const aMethod: TRttiMethod);
begin
  FMethod := aMethod;
end;

{ TBehaviourReturnExpectedValue<T> }

constructor TBehaviourReturnValue<T>.Create(aExpectedResult: TValue);
begin
  inherited Create;
  FExpectedResult := aExpectedResult;
end;

{ TBehaviourExecuteMethod<T, M> }

constructor TBehaviourExecuteMethod<T, M>.Create(aMethodWillBeExecuted: M);
begin
  inherited Create;
  FMethodWillBeExecuted := aMethodWillBeExecuted;
end;

function TBehaviourExecuteMethod<T, M>.GetMethodWillBeExecuted: M;
begin
  Result := FMethodWillBeExecuted;
end;

function TBehaviourReturnValue<T>.GetExpectedResult: TValue;
begin
  Result := FExpectedResult;
end;

end.
