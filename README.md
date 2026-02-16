# AI Post Maker
Rails 8 + Phlex + Hotwire tabanli, ComfyUI ile gorsel uretip paylasim akisini yoneten yerel (self-hosted) bir AI icerik uygulamasi.

## Ozellikler
- Prompt tabanli gorsel uretim (ComfyUI HTTP API ile)
- Arka planda job isleme (Sidekiq + Redis)
- Prompttan otomatik caption varyantlari uretimi
- Durum takibi: `queued`, `processing`, `generated`, `failed`, `canceled`
- Turbo/Hotwire ile canli dashboard guncellemesi
- Phlex bilesen tabanli UI + Bootstrap 5
- Devise ile kimlik dogrulama
- Share landing sayfasi (`/p/:id`) ve temel sosyal paylasim aksiyonlari

## Demo / Ekran Goruntusu
_Henuz eklenmedi. Buraya ekran goruntusu veya GIF ekleyin._

## Gereksinimler
- Ruby `3.4.x` (`.ruby-version`: `ruby-3.4.2`)
- Rails `8.x`
- PostgreSQL `16+` (veya PostgreSQL uyumlu bir surum)
- Redis `7+`
- Bundler
- Docker ve Docker Compose (Docker kurulumu icin)
- Opsiyonel: ComfyUI (varsayilan: `http://localhost:8188` / Docker icinde `http://host.docker.internal:8188`)

## Hizli Baslangic (Local)
1. Ortam dosyasini olusturun:
```bash
cp .env.example .env
```

2. `.env` icinde en az su degiskenleri doldurun: `DATABASE_URL`, `REDIS_URL`, `RAILS_MASTER_KEY` (credentials kullaniyorsaniz), `COMFYUI_BASE_URL` (ComfyUI calisiyorsa).

3. Bagimliliklari kurun:
```bash
bundle install
```

4. Veritabanini hazirlayin:
```bash
bin/rails db:prepare
```

5. Uygulamayi iki ayri terminalde calistirin:
```bash
bin/rails server
```
```bash
bundle exec sidekiq
```

6. Uygulamayi acin: `http://localhost:3000`
7. Sidekiq paneli: `http://localhost:3000/sidekiq`

Not: `bin/dev` varsayilan olarak `Procfile.dev` bekler; bu repoda `Procfile.dev` bulunmadigi icin yukaridaki iki terminal yaklasimini kullanin.

## Docker ile Calistirma
1. Servisleri baslatin:
```bash
docker compose up -d --build db redis
```

2. Veritabanini hazirlayin:
```bash
docker compose run --rm web bin/rails db:prepare
```

3. Uygulamayi ve worker'i baslatin:
```bash
docker compose up --build web sidekiq
```

4. Erisim: `http://localhost:3000`
5. Sidekiq paneli: `http://localhost:3000/sidekiq`

Notlar:
`compose.yaml` icindeki varsayilan DB bilgileri gelistirme amaclidir (`efor/123456`).
Docker icinde ComfyUI icin varsayilan adres `http://host.docker.internal:8188`.

## Konfigurasyon
Asagidaki degiskenleri `.env` dosyasinda yonetin:

| ENV | Zorunlu | Varsayilan | Aciklama |
|---|---|---|---|
| `DATABASE_URL` | Evet | - | Rails ana veritabani baglantisi |
| `DATABASE_URL_PRODUCTION` | Hayir | `DATABASE_URL` | Production DB URL (opsiyonel override) |
| `REDIS_URL` | Evet | - | Sidekiq Redis baglantisi |
| `RAILS_ENV` | Hayir | `development` | Calisma ortami |
| `RAILS_MASTER_KEY` | Ortama bagli | - | Rails credentials cozumleme anahtari |
| `RAILS_MAX_THREADS` | Hayir | `5` (`database.yml`) / `3` (`puma.rb`) | Thread sayisi |
| `PORT` | Hayir | `3000` | Puma portu |
| `COMFYUI_BASE_URL` | ComfyUI icin evet | `http://host.docker.internal:8188` | ComfyUI HTTP endpoint |
| `COMFYUI_WORKFLOW_PATH` | Hayir | `config/comfyui/workflows/aimaker_image_v1.json` | Kullanilacak workflow JSON yolu |
| `COMFYUI_POLL_INTERVAL_SECONDS` | Hayir | `3` | ComfyUI cikti kontrol araligi |
| `COMFYUI_POLL_TIMEOUT_SECONDS` | Hayir | `600` | ComfyUI timeout suresi |
| `JOB_CONCURRENCY` | Hayir | `1` | Solid Queue isci sureci sayisi (yalniz `bin/jobs` icin) |
| `OPENAI_API_KEY` | Hayir | - | Gelecek provider/entegrasyonlar icin yer tutucu |
| `STABILITY_API_KEY` | Hayir | - | Gelecek provider/entegrasyonlar icin yer tutucu |
| `HUGGINGFACE_API_KEY` | Hayir | - | Gelecek provider/entegrasyonlar icin yer tutucu |
| `SMTP_ADDRESS` | Hayir | - | Mail sunucu adresi |
| `SMTP_PORT` | Hayir | - | Mail sunucu portu |
| `SMTP_USERNAME` | Hayir | - | Mail kullanici adi |
| `SMTP_PASSWORD` | Hayir | - | Mail sifresi |

## Entegrasyonlar
- ComfyUI (yerel provider): `POST /prompt` ile job baslatilir, `GET /history/:prompt_id` ile sonuc metadata alinir, `GET /view?...` ile dosya indirilir, dosya sistemi paylasimi beklenmez ve iletisim HTTP uzerindendir.
- Active Storage: uretilen varliklar development/test ortaminda `storage/` altinda saklanir.
- Sidekiq: `GenerateImageJob` ve `GenerateCaptionJob` arka planda calisir.

## Kullanim
Ornek akis:
1. Kayit ol / giris yap.
2. Ana ekranda prompt girin, cikti turu olarak `image` secin (video secimi su an devre disi).
3. Dil (`tr`/`en`) ve ton (`friendly`/`formal`) secin.
4. Gonderdikten sonra `GenerateImageJob` ComfyUI ile gorsel uretir ve `GenerateCaptionJob` caption varyantlari olusturur.
5. Dashboard kartinda durumu takip edin (`queued -> processing -> generated`).
6. Uretilen icerigi indirin, caption kopyalayin, paylasim modalini kullanin veya paylasim sayfasini acin (`/p/:id`).
7. Gerekiyorsa islemdeki isi iptal edin (`cancel`) veya postu silin.

## Gelistirme
Teknoloji yigini:
- Rails 8
- Phlex + Phlex-Rails
- Turbo + Stimulus (Hotwire)
- Bootstrap 5 + `bootstrap_form`
- PostgreSQL
- Sidekiq + Redis
- Active Storage (local disk)
- Devise

Mimari ozet:
- UI: `app/components/**` (Phlex)
- Controller katmani: `app/controllers/**`
- Domain modelleri: `app/models/**`
- Servisler: `app/services/comfyui_client.rb`, `app/services/comfyui_image_service.rb`, `app/services/local_caption_service.rb`
- Arka plan joblari: `app/jobs/generate_image_job.rb`, `app/jobs/generate_caption_job.rb`
- ComfyUI workflowlari: `config/comfyui/workflows/**`

Onemli servisler:
- PostgreSQL: kalici uygulama verisi
- Redis: Sidekiq kuyruk altyapisi
- Sidekiq: background worker

### Troubleshooting
1. `Redis connection` hatasi:
   Redis'i baslatin (`redis-server` veya `docker compose up -d redis`) ve `REDIS_URL` degerini kontrol edin.
2. Sidekiq job'lari islenmiyor:
   `bundle exec sidekiq` prosesinin calistigini dogrulayin ve `/sidekiq` ekranindan kuyrugu kontrol edin.
3. `PG::ConnectionBad` / DB baglanti hatasi:
   PostgreSQL'in calistigini ve `DATABASE_URL` formatini kontrol edin; gerekirse `bin/rails db:prepare` calistirin.
4. `PendingMigrationError`:
   `bin/rails db:migrate` veya `bin/rails db:prepare` calistirin.
5. ComfyUI timeout veya baglanti hatasi:
   `COMFYUI_BASE_URL` degerini ve ComfyUI sunucusunun ayakta oldugunu kontrol edin; gerekirse `COMFYUI_POLL_TIMEOUT_SECONDS` degerini artirin.
6. `Workflow bulunamadi` hatasi:
   `COMFYUI_WORKFLOW_PATH` dosya yolunu ve varsayilan dosyanin varligini kontrol edin: `config/comfyui/workflows/aimaker_image_v1.json`.
7. `bin/dev` calismiyor:
   Bu repoda `Procfile.dev` yok; `bin/rails server` ve `bundle exec sidekiq` komutlarini ayri terminallerde calistirin.
8. Gorseller gorunmuyor / Active Storage sorunu:
   Development ortaminda local disk (`storage/`) kullanilir; veritabani ve Active Storage tablolarinin olustugunu `bin/rails db:prepare` ile dogrulayin.
9. Credentials hatasi (`Missing RAILS_MASTER_KEY`):
   Gerekliyse `.env` icine `RAILS_MASTER_KEY` ekleyin.
10. Docker icinden ComfyUI'ye erisim yok:
   ComfyUI host makinede calisiyorsa `host.docker.internal:8188` kullanin; Linux ortaminda host erisimi icin Docker ag ayarlarinizi dogrulayin.

## Test & Lint
Tum testler:
```bash
bin/rails test
```

Belirli test dosyasi:
```bash
bin/rails test test/jobs/generate_image_job_test.rb
```

Lint:
```bash
bin/rubocop
```

Guvenlik taramasi:
```bash
bin/brakeman
```

## Dagitim
- Uygulama Docker imaji ile dagitima uygundur.
- `config/deploy.yml` Kamal icin ornek konfigurasyon icerir; production degerleri proje ortamina gore guncellenmelidir.
- Production ortaminda gerekli minimumlar: `RAILS_MASTER_KEY`, `DATABASE_URL` (veya `DATABASE_URL_PRODUCTION`), `REDIS_URL`, `COMFYUI_BASE_URL` (ComfyUI kullanilacaksa).

## Katki
- Kucuk ve odakli PR'lar acin.
- Degisiklikten once test/lint calistirin.
- Mimari kurallari koruyun: yeni UI icin Phlex, form icin `bootstrap_form`, stil icin Bootstrap 5.
- Issue takibi icin `bd` (beads) kullanin.

## Lisans
TBD

## Degisiklik Ozeti
- README tamamen yeniden yazildi ve proje odakli hale getirildi.
- Local kurulum adimlari calisir komutlarla netlestirildi.
- Docker akisi ayri baslikta, sirali ve uygulanabilir komutlarla eklendi.
- ENV degiskenleri tablo formatinda toplanip gercek kod kullanimlarina gore duzenlendi.
- Rails/Phlex/Hotwire, Sidekiq/Redis/Postgres ve mimari katmanlar aciklandi.
- ComfyUI entegrasyonu ve HTTP tabanli pipeline netlestirildi.
- Kullanici akisinin adim adim calisma sekli eklendi.
- Test, lint ve guvenlik tarama komutlari dogrulandi.
- Dagitim notlari Kamal ve temel production gereksinimleriyle kisaltildi.
- 10 maddelik troubleshooting bolumu eklendi.
