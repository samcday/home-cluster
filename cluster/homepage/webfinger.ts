// Simple proxy that returns Mastodon webfinger result, but also inserts OIDC discovery data
Deno.serve(async (req: Request) => {
  const u = new URL(req.url);
  console.log(req.url);
  if (u.pathname == "/") {
    return new Response("OK"); // simple health-check for k8s
  }
  const resource = u.searchParams.get("resource");
  if (!resource) {
    return new Response(null, {status: 404});
  }
  const resp = await fetch(`https://mastodon.samcday.com/.well-known/webfinger?resource=${resource}`);
  if (resp.status !== 200) {
    return resp;
  }
  const mastodon = await resp.json();
  if (decodeURIComponent(resource) == "acct:me@samcday.com") {
    mastodon.links.push({
      rel: "http://openid.net/specs/connect/1.0/issuer",
      href: "https://dex.samcday.com",
    });
  }
  return new Response(JSON.stringify(mastodon), {
    headers: {
      "content-type": "application/json; charset=utf-8",
    },
  });
});
