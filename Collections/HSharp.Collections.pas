unit HSharp.Collections;

interface

uses
  HSharp.Collections.Interfaces,
  HSharp.Collections.Dictionary,
  HSharp.Collections.List,
  HSharp.Collections.Stack;

type
  Collections = class
  public
    class function CreateList<T>: IList<T>;
    class function CreateDictionary<TKey,TValue>: IDictionary<TKey,TValue>;
    class function CreateStack<T>: IStack<T>;
  end;

implementation

{ Collections }

class function Collections.CreateDictionary<TKey, TValue>: IDictionary<TKey,TValue>;
begin
  Result := TInterfacedDictionary<TKey,TValue>.Create;
end;

class function Collections.CreateList<T>: IList<T>;
begin
  Result := TInterfacedList<T>.Create;
end;

class function Collections.CreateStack<T>: IStack<T>;
begin
  Result := TInterfacedStack<T>.Create;
end;

end.
