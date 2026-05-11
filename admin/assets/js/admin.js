(function setupAdminSidebar() {
    var navLinks = document.querySelectorAll(".admin-nav a.admin-nav-link");
    var submenuLinks = document.querySelectorAll(".admin-submenu a");
    var toggles = document.querySelectorAll(".admin-nav-link.has-arrow[data-toggle-submenu]");
    var toggleButton = document.getElementById("adminSidebarToggle");
    var isDesktop = window.matchMedia("(min-width: 992px)");
    var currentPath = window.location.pathname.split("/").pop().toLowerCase();
    var currentQuery = window.location.search.toLowerCase();
    var currentFull = currentPath + currentQuery;

    if (navLinks.length) {
        navLinks.forEach(function (link) {
            var linkPage = (link.getAttribute("href") || "").toLowerCase();
            if (linkPage && linkPage !== "javascript:void(0)" && (currentPath === linkPage || currentFull === linkPage)) {
                link.classList.add("active");
            }
        });
    }

    if (submenuLinks.length) {
        submenuLinks.forEach(function (link) {
            var linkPage = (link.getAttribute("href") || "").toLowerCase();
            if (linkPage && linkPage !== "javascript:void(0)" && (currentPath === linkPage || currentFull === linkPage)) {
                link.classList.add("active");

                var parentItem = link.closest(".admin-nav-item");
                if (parentItem) {
                    parentItem.classList.add("open");
                    var parentLink = parentItem.querySelector(".admin-nav-link");
                    if (parentLink) {
                        parentLink.classList.add("active");
                    }
                }
            }
        });
    }

    if (toggles.length) {
        toggles.forEach(function (toggle) {
            toggle.addEventListener("click", function (event) {
                var href = (toggle.getAttribute("href") || "").toLowerCase();
                if (href && href !== "javascript:void(0)" && !toggle.classList.contains("active")) {
                    return;
                }

                event.preventDefault();

                var submenuId = toggle.getAttribute("data-toggle-submenu");
                var submenu = submenuId ? document.getElementById(submenuId) : null;
                var parentItem = toggle.closest(".admin-nav-item");

                if (!submenu || !parentItem) {
                    return;
                }

                var willOpen = !parentItem.classList.contains("open");

                toggles.forEach(function (otherToggle) {
                    var otherItem = otherToggle.closest(".admin-nav-item");
                    if (otherItem && otherItem !== parentItem) {
                        otherItem.classList.remove("open");
                    }
                });

                if (willOpen) {
                    parentItem.classList.add("open");
                } else {
                    parentItem.classList.remove("open");
                }
            });
        });
    }

    if (!toggleButton) {
        return;
    }

    var collapsedState = localStorage.getItem("adminSidebarCollapsed") === "true";
    if (collapsedState && isDesktop.matches) {
        document.body.classList.add("sidebar-collapsed");
    }

    toggleButton.addEventListener("click", function () {
        if (isDesktop.matches) {
            document.body.classList.toggle("sidebar-collapsed");
            localStorage.setItem("adminSidebarCollapsed", document.body.classList.contains("sidebar-collapsed"));
            return;
        }

        document.body.classList.toggle("sidebar-open");
    });

    window.addEventListener("resize", function () {
        if (isDesktop.matches) {
            document.body.classList.remove("sidebar-open");
            if (localStorage.getItem("adminSidebarCollapsed") === "true") {
                document.body.classList.add("sidebar-collapsed");
            } else {
                document.body.classList.remove("sidebar-collapsed");
            }
        } else {
            document.body.classList.remove("sidebar-collapsed");
        }
    });

    document.addEventListener("click", function (event) {
        if (isDesktop.matches || !document.body.classList.contains("sidebar-open")) {
            return;
        }

        var sidebar = document.querySelector(".admin-sidebar");
        var isClickInsideSidebar = sidebar && sidebar.contains(event.target);
        var isClickOnToggle = toggleButton.contains(event.target);

        if (!isClickInsideSidebar && !isClickOnToggle) {
            document.body.classList.remove("sidebar-open");
        }
    });
})();

(function setupTopbarPanels() {
    var panelButtons = document.querySelectorAll("[data-topbar-panel]");
    var fullscreenBtn = document.getElementById("adminFullscreenBtn");

    if (panelButtons.length) {
        panelButtons.forEach(function (btn) {
            btn.addEventListener("click", function (event) {
                event.preventDefault();
                event.stopPropagation();

                var panelId = btn.getAttribute("data-topbar-panel");
                var wrapper = btn.closest(".admin-topbar-item");
                if (!panelId || !wrapper) {
                    return;
                }

                var shouldOpen = !wrapper.classList.contains("open");
                var wrappers = document.querySelectorAll(".admin-topbar-item");
                wrappers.forEach(function (item) {
                    item.classList.remove("open");
                });

                if (shouldOpen) {
                    wrapper.classList.add("open");
                }
            });
        });

        document.addEventListener("click", function (event) {
            var clickedInside = event.target.closest(".admin-topbar-item");
            if (!clickedInside) {
                var wrappers = document.querySelectorAll(".admin-topbar-item");
                wrappers.forEach(function (item) {
                    item.classList.remove("open");
                });
            }
        });
    }

    if (fullscreenBtn) {
        fullscreenBtn.addEventListener("click", function () {
            if (!document.fullscreenElement) {
                document.documentElement.requestFullscreen();
                return;
            }

            if (document.exitFullscreen) {
                document.exitFullscreen();
            }
        });
    }
})();

(function setupAdminTopSearch() {
    var input = document.getElementById("adminTopSearchInput");
    var resultsBox = document.getElementById("adminSearchResults");
    if (!input || !resultsBox) {
        return;
    }

    var uniqueLinks = {};
    var items = [];
    var links = document.querySelectorAll(".admin-nav a[href]");
    links.forEach(function (link) {
        var href = (link.getAttribute("href") || "").trim();
        var label = (link.textContent || "").trim().replace(/\s+/g, " ");
        if (!href || !label || href === "#") {
            return;
        }

        var key = href.toLowerCase() + "|" + label.toLowerCase();
        if (uniqueLinks[key]) {
            return;
        }
        uniqueLinks[key] = true;

        items.push({
            href: href,
            label: label
        });
    });

    function renderList(filtered) {
        if (!filtered.length) {
            resultsBox.innerHTML = '<div class="admin-search-empty">No matching pages found.</div>';
            resultsBox.classList.add("show");
            return;
        }

        var html = filtered.slice(0, 10).map(function (item) {
            return '<a class="admin-search-item" href="' + item.href + '"><i class="fas fa-arrow-right"></i><span>' + item.label + "</span></a>";
        }).join("");
        resultsBox.innerHTML = html;
        resultsBox.classList.add("show");
    }

    input.addEventListener("input", function () {
        var query = input.value.trim().toLowerCase();
        if (!query) {
            resultsBox.classList.remove("show");
            resultsBox.innerHTML = "";
            return;
        }

        var filtered = items.filter(function (item) {
            return item.label.toLowerCase().indexOf(query) !== -1 || item.href.toLowerCase().indexOf(query) !== -1;
        });
        renderList(filtered);
    });

    input.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            var first = resultsBox.querySelector(".admin-search-item");
            if (first) {
                event.preventDefault();
                window.location.href = first.getAttribute("href");
            }
        }
    });

    document.addEventListener("click", function (event) {
        var clickedInside = event.target.closest(".admin-topbar-search");
        if (!clickedInside) {
            resultsBox.classList.remove("show");
        }
    });
})();
