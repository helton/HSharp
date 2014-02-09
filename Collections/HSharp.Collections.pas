unit HSharp.Collections;

interface

uses
  HSharp.Collections.Interfaces,
  HSharp.Collections.Dictionary,
  HSharp.Collections.List;

type
  Collections = class
  public
    class function CreateList<T>: IList<T>;
    class function CreateDictionary<TKey,TValue>: IDictionary<TKey,TValue>;
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

end.
