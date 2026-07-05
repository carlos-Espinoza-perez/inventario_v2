// Proxy autenticado hacia la API de OpenAI.
//
// La OPENAI_API_KEY vive como secreto del servidor (supabase secrets set) y
// nunca viaja en el APK. Supabase valida el JWT del usuario antes de invocar
// esta función (verify_jwt habilitado por defecto), por lo que solo usuarios
// autenticados de la app pueden consumirla.
//
// Reenvía el body tal cual a chat/completions y devuelve la respuesta,
// incluyendo passthrough del stream SSE cuando request.stream = true.

const OPENAI_URL = "https://api.openai.com/v1/chat/completions";

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Método no permitido" }),
      { status: 405, headers: { "Content-Type": "application/json" } },
    );
  }

  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "OPENAI_API_KEY no configurada en el servidor" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  const upstream = await fetch(OPENAI_URL, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: req.body,
  });

  return new Response(upstream.body, {
    status: upstream.status,
    headers: {
      "Content-Type":
        upstream.headers.get("Content-Type") ?? "application/json",
    },
  });
});
