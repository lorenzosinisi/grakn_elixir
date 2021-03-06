defmodule Grakn.Session do

  @opaque t :: GRPC.Channel.t()

  @spec new(String.t()) :: t()
  def new(uri) do
    GRPC.Stub.connect(uri)
  end

  @spec transaction(t()) :: {:ok, Grakn.Transaction.t()} | {:error, any()}
  @spec transaction(GRPC.Channel) ::
          {:ok,
           {{:error, map()} | {:ok, any()} | {:ok, map(), map()} | GRPC.Client.Stream.t(), []}}
  def transaction(channel) do
    channel
    |> Grakn.Transaction.new()
  end

  @spec command(t(), Grakn.Command.command(), keyword()) :: {:ok, any()} | {:error, any()}
  def command(channel, :get_keyspaces, _) do
    request = Keyspace.Keyspace.Retrieve.Req.new()
    channel
    |> Keyspace.KeyspaceService.Stub.retrieve(request)
    |> case do
      {:ok, %Keyspace.Keyspace.Retrieve.Res{names: names}} -> {:ok, names}
      error -> error
    end
  end

  def command(channel, :create_keyspace, [name: name]) do
    request = Keyspace.Keyspace.Create.Req.new(name: name)
    channel
    |> Keyspace.KeyspaceService.Stub.create(request)
    |> case do
      {:ok, %Keyspace.Keyspace.Create.Res{}} -> {:ok, nil}
      error -> error
    end
  end

  def command(channel, :delete_keyspace, [name: name]) do
    request = Keyspace.Keyspace.Delete.Req.new(name: name)
    channel
    |> Keyspace.KeyspaceService.Stub.delete(request)
    |> case do
      {:ok, %Keyspace.Keyspace.Delete.Res{}} -> {:ok, nil}
      error -> error
    end
  end

  @spec close(t()) :: :ok
  def close(channel) do
    channel
    |> GRPC.Stub.end_stream()
    :ok
  end
end
