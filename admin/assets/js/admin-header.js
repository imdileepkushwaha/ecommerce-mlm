(function () {
    function $(id) { return document.getElementById(id); }

    function getAdminBasePath() {
        var path = window.location.pathname || '';
        var idx = path.lastIndexOf('/');
        return idx >= 0 ? path.substring(0, idx + 1) : '/admin/';
    }

    function getSearchUrl() {
        return getAdminBasePath() + 'AdminSearch.ashx';
    }

    function closeAllDropdowns(except) {
        ['hdrSearchResults', 'hdrNotifPanel', 'hdrAppsMenu', 'hdrProfileMenu'].forEach(function (id) {
            var el = $(id);
            if (el && el !== except) el.classList.remove('open');
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        var searchInput = $('hdrSearchInput');
        var searchBox = $('hdrSearchResults');
        var searchTimer = null;

        if (searchInput && searchBox) {
            searchInput.addEventListener('input', function () {
                var q = searchInput.value.trim();
                clearTimeout(searchTimer);
                if (q.length < 2) {
                    searchBox.classList.remove('open');
                    searchBox.innerHTML = '';
                    return;
                }
                searchTimer = setTimeout(function () {
                    fetch(getSearchUrl() + '?q=' + encodeURIComponent(q), {
                        credentials: 'same-origin',
                        headers: { 'X-Requested-With': 'XMLHttpRequest' }
                    })
                        .then(function (r) {
                            if (!r.ok) {
                                throw new Error('HTTP ' + r.status);
                            }
                            return r.text();
                        })
                        .then(function (text) {
                            var data;
                            try {
                                data = JSON.parse(text);
                            } catch (e) {
                                throw new Error('Invalid response');
                            }

                            if (data.error && (!data.results || !data.results.length)) {
                                searchBox.innerHTML = '<div class="hdr-drop-empty">' + escapeHtml(data.error) + '</div>';
                                searchBox.classList.add('open');
                                return;
                            }

                            var items = data.results || [];
                            if (!items.length) {
                                searchBox.innerHTML = '<div class="hdr-drop-empty">No results found</div>';
                            } else {
                                searchBox.innerHTML = items.map(function (item) {
                                    var icon = item.type === 'user' ? 'fa-user' : item.type === 'order' ? 'fa-receipt' : 'fa-store';
                                    var label = item.type === 'user' ? 'User' : item.type === 'order' ? 'Order' : 'Seller';
                                    return '<a href="' + escapeHtml(item.url) + '" class="hdr-search-item">' +
                                        '<span class="hdr-search-item-ico"><i class="fas ' + icon + '"></i></span>' +
                                        '<span class="hdr-search-item-body"><strong>' + escapeHtml(item.title) + '</strong>' +
                                        '<span>' + label + ' · ' + escapeHtml(item.subtitle || '') + '</span></span></a>';
                                }).join('');
                            }
                            searchBox.classList.add('open');
                            closeAllDropdowns(searchBox);
                        })
                        .catch(function (err) {
                            searchBox.innerHTML = '<div class="hdr-drop-empty">Search unavailable. Refresh and try again.</div>';
                            searchBox.classList.add('open');
                        });
                }, 280);
            });

            searchInput.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' && searchInput.value.trim().length >= 2) {
                    window.location.href = getAdminBasePath() + 'ManageUsers.aspx?q=' + encodeURIComponent(searchInput.value.trim());
                }
                if (e.key === 'Escape') {
                    searchBox.classList.remove('open');
                    searchInput.blur();
                }
            });

            searchInput.addEventListener('focus', function () {
                if (searchInput.value.trim().length >= 2 && searchBox.innerHTML) {
                    searchBox.classList.add('open');
                }
            });
        }

        var btnFullscreen = $('btnFullscreen');
        if (btnFullscreen) {
            btnFullscreen.addEventListener('click', function () {
                if (!document.fullscreenElement) {
                    document.documentElement.requestFullscreen().catch(function () { });
                } else {
                    document.exitFullscreen();
                }
            });
        }

        var btnApps = $('btnAppsToggle');
        var appsPanel = $('hdrAppsMenu');
        if (btnApps && appsPanel) {
            btnApps.addEventListener('click', function (e) {
                e.stopPropagation();
                appsPanel.classList.toggle('open');
                closeAllDropdowns(appsPanel.classList.contains('open') ? appsPanel : null);
            });
        }

        var btnNotif = $('btnNotif');
        var notifPanel = $('hdrNotifPanel');
        if (btnNotif && notifPanel) {
            btnNotif.addEventListener('click', function (e) {
                e.stopPropagation();
                notifPanel.classList.toggle('open');
                var dot = document.querySelector('.hdr-notif-dot');
                if (notifPanel.classList.contains('open') && dot) {
                    dot.style.display = 'none';
                }
                closeAllDropdowns(notifPanel.classList.contains('open') ? notifPanel : null);
            });
        }

        var btnProfile = $('btnProfile');
        var profileMenu = $('hdrProfileMenu');
        if (btnProfile && profileMenu) {
            btnProfile.addEventListener('click', function (e) {
                e.stopPropagation();
                profileMenu.classList.toggle('open');
                closeAllDropdowns(profileMenu.classList.contains('open') ? profileMenu : null);
            });
        }

        document.addEventListener('click', function () {
            closeAllDropdowns(null);
        });

        document.querySelectorAll('.hdr-dropdown, .hdr-search-dropdown').forEach(function (el) {
            el.addEventListener('click', function (e) { e.stopPropagation(); });
        });
    });

    function escapeHtml(str) {
        if (!str) return '';
        return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
})();
