/*
 * SPDX-FileCopyrightText: 2025 Wavelens GmbH <info@wavelens.io>
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

{ pkgs, lib, ... }: let
  staticPathsValues = attrs: builtins.attrValues (lib.optionalAttrs (builtins.hasAttr "static-paths" attrs) attrs.static-paths);
  # global rib -a ipv4 add <PREFIX> [identifier <VALUE>] [origin { igp | egp | incomplete }] [aspath <ASPATH>] [nexthop <ADDRESS>] [med <NUM>] [local-pref <NUM>] [community <COMMUNITY>] [aigp metric <NUM>] [large-community <LARGE_COMMUNITY>] [aggregator <AGGREGATOR>]
  setAttribute = attrs: name: attrs-name: if (builtins.hasAttr attrs-name attrs) then
    "${name} ${toString attrs.${attrs-name}}"
  else
    "";

  containsColon = str: builtins.any (v: v == ":") (lib.stringToCharacters str);
  family = v: if (containsColon v.prefix) then "ipv6" else "ipv4";

  setAttributes = attrs: attrsMap: builtins.concatStringsSep " " (lib.filter (s: s != "") (lib.mapAttrsToList (k: kv: setAttribute attrs k kv) attrsMap));
in attrs: map (v: "${lib.getExe pkgs.gobgp} global rib -a ${family v} add ${v.prefix} ${setAttributes attrs {
  "identifier" = "identifier";
  "origin" = "origin";
  "aspath" = "aspath";
  "nexthop" = "nexthop";
  "med" = "med";
  "local-pref" = "local-pref";
  "community" = "community";
  "aigp-metric" = "aigp metric";
  "large-community" = "large-community";
  "aggregator" = "aggregator";
}}") (staticPathsValues attrs)
