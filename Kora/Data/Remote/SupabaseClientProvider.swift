//
//  SupabaseClientProvider.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import Supabase

enum SupabaseClientProvider {
    static let client = SupabaseClient(
        supabaseURL: AppConfig.supabaseURL,
        supabaseKey: AppConfig.supabaseKey
    )
}
