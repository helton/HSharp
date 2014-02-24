unit HSharp.PEG.Context;

interface

uses
  HSharp.Collections.Interfaces,
  HSharp.Collections,
  HSharp.PEG.Context.Interfaces;

type
  TContext = class(TInterfacedObject, IContext)
  strict private
    FText: string;
    FIndex: Integer;
    FState: IStack<Integer>;
  private
    function GetText: string;
    function GetIndex: Integer;
  public
    procedure IncIndex(aOffset: Integer);
    procedure SaveState;
    procedure RestoreState;
    constructor Create(const aText: String); reintroduce;
  end;

implementation

uses
  System.StrUtils;

{ TContext }

constructor TContext.Create(const aText: String);
begin
  inherited Create;
  FText  := aText;
  FState := Collections.CreateStack<Integer>;
end;

function TContext.GetIndex: Integer;
begin
  Result := FIndex;
end;

function TContext.GetText: string;
begin
  Result := RightStr(FText, Length(FText) - FIndex);
end;

procedure TContext.IncIndex(aOffset: Integer);
begin
  Inc(FIndex, aOffset);
end;

procedure TContext.RestoreState;
begin
  FIndex := FState.Pop;
end;

procedure TContext.SaveState;
begin
  FState.Push(FIndex);
end;

end.
