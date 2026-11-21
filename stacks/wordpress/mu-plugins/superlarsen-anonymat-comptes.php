<?php
/**
 * Plugin Name: Superlarsen — anonymat des comptes
 * Description: Ne publie pas la liste des comptes aux visiteurs non connectés.
 *
 * Le 2026-11-19, une rafale de « mot de passe oublié » a visé chaque compte du site,
 * à partir des identifiants que WordPress publiait. Quatre portes sont fermées ici :
 *   - /wp-json/wp/v2/users et ?rest_route=/wp/v2/users (API REST) ;
 *   - ?author=N (redirection vers /author/<identifiant>/) ;
 *   - /author-sitemap.xml (sitemap des auteurs de Yoast).
 *
 * ponytail: les pages /author/<identifiant>/ restent publiques, car le site s'en sert.
 * Les identifiants restent donc découvrables à la main. Contre les rafales, c'est le défi
 * Cloudflare sur lostpassword qui protège, pas ce fichier.
 */

// API REST : les routes users disparaissent pour un anonyme. L'éditeur envoie un nonce,
// donc il reste authentifié et garde le choix de l'auteur.
add_filter('rest_endpoints', function ($endpoints) {
    if (is_user_logged_in()) {
        return $endpoints;
    }
    foreach (array_keys($endpoints) as $route) {
        if (strpos($route, '/wp/v2/users') === 0) {
            unset($endpoints[$route]);
        }
    }
    return $endpoints;
});

// ?author=N : 404 avant que redirect_canonical (priorité 10) ne révèle l'identifiant.
add_action('template_redirect', function () {
    if (isset($_GET['author']) && !is_user_logged_in()) {
        global $wp_query;
        $wp_query->set_404();
        status_header(404);
        nocache_headers();
    }
}, 1);

// Yoast : aucun auteur dans le sitemap.
add_filter('wpseo_sitemap_exclude_author', '__return_empty_array');
