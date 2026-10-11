/* DMG asset downloads across every GitHub release, shown under the hero CTA.
   These are downloads, not unique people or installed copies. Feed and
   checksum fetches must not inflate the count.
   Unauthenticated GitHub API allows 60 requests an hour per IP, so the total
   is cached in sessionStorage for 10 minutes. Any failure leaves it hidden. */
(function () {
  var el = document.querySelector("[data-download-count]");
  if (!el || !window.fetch) return;

  var API = "https://api.github.com/repos/UmarSiddiqui/heymate/releases?per_page=100";
  var KEY = "heymate.dmg-downloads.v1";
  var TTL = 10 * 60 * 1000;

  // 950 -> "950", 1234 -> "1.2k", 999999 -> "1M".
  function format(n) {
    try {
      return new Intl.NumberFormat("en-US", { notation: "compact", maximumFractionDigits: 1 })
        .format(n).replace("K", "k");
    } catch (e) {
      return n.toLocaleString("en-US");
    }
  }

  function show(total) {
    if (!total) return;
    el.textContent = format(total) + " downloads";
    el.title = total.toLocaleString("en-US") + " DMG downloads across all releases; not unique users";
    el.hidden = false;
  }

  function next(link) {
    var m = link && link.match(/<([^>]+)>;\s*rel="next"/);
    return m ? m[1] : null;
  }

  function sum(url, total) {
    return fetch(url, { headers: { Accept: "application/vnd.github+json" } }).then(function (res) {
      if (!res.ok) throw new Error(res.status);
      var more = next(res.headers.get("Link"));
      return res.json().then(function (releases) {
        releases.forEach(function (r) {
          (r.assets || []).forEach(function (a) {
            if (a.name === "HeyMate.dmg") total += a.download_count || 0;
          });
        });
        return more ? sum(more, total) : total;
      });
    });
  }

  try {
    var cached = JSON.parse(sessionStorage.getItem(KEY) || "null");
    if (cached && Date.now() - cached.at < TTL) return show(cached.total);
  } catch (e) {}

  sum(API, 0).then(function (total) {
    try { sessionStorage.setItem(KEY, JSON.stringify({ total: total, at: Date.now() })); } catch (e) {}
    show(total);
  }, function () {});
})();
