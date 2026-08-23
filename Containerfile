FROM elixir:1.17-slim AS build

WORKDIR /app
ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY vendor/ vendor/
RUN mix deps.get

COPY config/ config/
COPY lib/ lib/
RUN mix compile && mix release

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      libncurses6 \
      libssl3 \
      zlib1g \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --system --create-home bees
WORKDIR /app
COPY --from=build --chown=bees:bees /app/_build/prod/rel/bees_with_scope ./

USER bees

ENV PORT=4000
EXPOSE 4000

CMD ["bin/bees_with_scope", "start"]
