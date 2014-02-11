unit HSharp.Container.Types;

interface

type
  TActivatorDelegate<T: class> = reference to function: T;
  TLifetimeType = (Singleton, Transient, Delegation);

implementation

end.
