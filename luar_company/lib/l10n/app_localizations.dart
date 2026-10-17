import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'Luar Mobiliario'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In pt, this message translates to:
  /// **'Seu novo lar começa aqui'**
  String get appTagline;

  /// No description provided for @versao.
  ///
  /// In pt, this message translates to:
  /// **'Versão {v}'**
  String versao(Object v);

  /// No description provided for @notificacoes.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificacoes;

  /// No description provided for @notifMensagens.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens'**
  String get notifMensagens;

  /// No description provided for @notifMensagensDesc.
  ///
  /// In pt, this message translates to:
  /// **'Novas mensagens de conversa'**
  String get notifMensagensDesc;

  /// No description provided for @notifAgendamentos.
  ///
  /// In pt, this message translates to:
  /// **'Agendamentos'**
  String get notifAgendamentos;

  /// No description provided for @notifAgendamentosDesc.
  ///
  /// In pt, this message translates to:
  /// **'Atualizações de agendamentos e visitas'**
  String get notifAgendamentosDesc;

  /// No description provided for @notifAnuncios.
  ///
  /// In pt, this message translates to:
  /// **'Anúncios'**
  String get notifAnuncios;

  /// No description provided for @notifAnunciosDesc.
  ///
  /// In pt, this message translates to:
  /// **'Novos anúncios e destaques'**
  String get notifAnunciosDesc;

  /// No description provided for @notifPromocoes.
  ///
  /// In pt, this message translates to:
  /// **'Promoções'**
  String get notifPromocoes;

  /// No description provided for @notifPromocoesDesc.
  ///
  /// In pt, this message translates to:
  /// **'Novidades e promoções'**
  String get notifPromocoesDesc;

  /// No description provided for @notifSistema.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get notifSistema;

  /// No description provided for @notifSistemaDesc.
  ///
  /// In pt, this message translates to:
  /// **'Notificações gerais da aplicação'**
  String get notifSistemaDesc;

  /// No description provided for @explorarImoveis.
  ///
  /// In pt, this message translates to:
  /// **'Explorar Imóveis'**
  String get explorarImoveis;

  /// No description provided for @versaoApp.
  ///
  /// In pt, this message translates to:
  /// **'Versão {v}'**
  String versaoApp(Object v);

  /// No description provided for @welcomeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Explore os nossos imóveis e terrenos. Para agendar uma visita, basta indicar o seu nome e telefone.'**
  String get welcomeDesc;

  /// No description provided for @homeSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar por localização, tipo...'**
  String get homeSearchHint;

  /// No description provided for @homeHeroTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encontre o seu\nimóvel ideal'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Casas, apartamentos, terrenos e mais'**
  String get homeHeroSubtitle;

  /// No description provided for @categorias.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get categorias;

  /// No description provided for @verTodas.
  ///
  /// In pt, this message translates to:
  /// **'Ver todas'**
  String get verTodas;

  /// No description provided for @verTodos.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get verTodos;

  /// No description provided for @verMais.
  ///
  /// In pt, this message translates to:
  /// **'Ver mais'**
  String get verMais;

  /// No description provided for @verMenos.
  ///
  /// In pt, this message translates to:
  /// **'Ver menos'**
  String get verMenos;

  /// No description provided for @casas.
  ///
  /// In pt, this message translates to:
  /// **'Casas'**
  String get casas;

  /// No description provided for @apartamentos.
  ///
  /// In pt, this message translates to:
  /// **'Apartamentos'**
  String get apartamentos;

  /// No description provided for @terrenos.
  ///
  /// In pt, this message translates to:
  /// **'Terrenos'**
  String get terrenos;

  /// No description provided for @fazendas.
  ///
  /// In pt, this message translates to:
  /// **'Fazendas'**
  String get fazendas;

  /// No description provided for @armazens.
  ///
  /// In pt, this message translates to:
  /// **'Armazéns'**
  String get armazens;

  /// No description provided for @terrenosDestaque.
  ///
  /// In pt, this message translates to:
  /// **'Terrenos em Destaque'**
  String get terrenosDestaque;

  /// No description provided for @imoveisDestaque.
  ///
  /// In pt, this message translates to:
  /// **'Imóveis em Destaque'**
  String get imoveisDestaque;

  /// No description provided for @nenhumImovelDestaque.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum imóvel em destaque no momento'**
  String get nenhumImovelDestaque;

  /// No description provided for @nenhumTerrenoDestaque.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum terreno em destaque no momento'**
  String get nenhumTerrenoDestaque;

  /// No description provided for @servicos.
  ///
  /// In pt, this message translates to:
  /// **'Serviços'**
  String get servicos;

  /// No description provided for @servicoCompra.
  ///
  /// In pt, this message translates to:
  /// **'Compra'**
  String get servicoCompra;

  /// No description provided for @servicoCompraDesc.
  ///
  /// In pt, this message translates to:
  /// **'Encontre o imóvel dos seus sonhos'**
  String get servicoCompraDesc;

  /// No description provided for @servicoVenda.
  ///
  /// In pt, this message translates to:
  /// **'Venda'**
  String get servicoVenda;

  /// No description provided for @servicoVendaDesc.
  ///
  /// In pt, this message translates to:
  /// **'Venda com segurança e rapidez'**
  String get servicoVendaDesc;

  /// No description provided for @servicoArrendamento.
  ///
  /// In pt, this message translates to:
  /// **'Arrendamento'**
  String get servicoArrendamento;

  /// No description provided for @servicoArrendamentoDesc.
  ///
  /// In pt, this message translates to:
  /// **'Alugue com as melhores condições'**
  String get servicoArrendamentoDesc;

  /// No description provided for @servicoConsultoria.
  ///
  /// In pt, this message translates to:
  /// **'Consultoria'**
  String get servicoConsultoria;

  /// No description provided for @servicoConsultoriaDesc.
  ///
  /// In pt, this message translates to:
  /// **'Assessoria personalizada'**
  String get servicoConsultoriaDesc;

  /// No description provided for @porqueEscolher.
  ///
  /// In pt, this message translates to:
  /// **'Por que escolher-nos?'**
  String get porqueEscolher;

  /// No description provided for @confiancaMercado.
  ///
  /// In pt, this message translates to:
  /// **'A confiança que o mercado reconhece'**
  String get confiancaMercado;

  /// No description provided for @beneficioExperiencia.
  ///
  /// In pt, this message translates to:
  /// **'Experiência no Mercado'**
  String get beneficioExperiencia;

  /// No description provided for @beneficioExperienciaDesc.
  ///
  /// In pt, this message translates to:
  /// **'Mais de 10 anos de atuação no mercado imobiliário angolano'**
  String get beneficioExperienciaDesc;

  /// No description provided for @beneficioAtendimento.
  ///
  /// In pt, this message translates to:
  /// **'Atendimento Personalizado'**
  String get beneficioAtendimento;

  /// No description provided for @beneficioAtendimentoDesc.
  ///
  /// In pt, this message translates to:
  /// **'Cada cliente recebe atenção dedicada e sob medida'**
  String get beneficioAtendimentoDesc;

  /// No description provided for @beneficioDocumentacao.
  ///
  /// In pt, this message translates to:
  /// **'Documentação Segura'**
  String get beneficioDocumentacao;

  /// No description provided for @beneficioDocumentacaoDesc.
  ///
  /// In pt, this message translates to:
  /// **'Cuidamos de toda a documentação com rigor e segurança'**
  String get beneficioDocumentacaoDesc;

  /// No description provided for @beneficioPrecos.
  ///
  /// In pt, this message translates to:
  /// **'Melhores Preços'**
  String get beneficioPrecos;

  /// No description provided for @beneficioPrecosDesc.
  ///
  /// In pt, this message translates to:
  /// **'Negociações transparentes e preços competitivos'**
  String get beneficioPrecosDesc;

  /// No description provided for @inicio.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get inicio;

  /// No description provided for @pesquisar.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar'**
  String get pesquisar;

  /// No description provided for @favoritos.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favoritos;

  /// No description provided for @perfil.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get perfil;

  /// No description provided for @urbano.
  ///
  /// In pt, this message translates to:
  /// **'Urbano'**
  String get urbano;

  /// No description provided for @agricola.
  ///
  /// In pt, this message translates to:
  /// **'Agrícola'**
  String get agricola;

  /// No description provided for @industrial.
  ///
  /// In pt, this message translates to:
  /// **'Industrial'**
  String get industrial;

  /// No description provided for @comercial.
  ///
  /// In pt, this message translates to:
  /// **'Comercial'**
  String get comercial;

  /// No description provided for @lote.
  ///
  /// In pt, this message translates to:
  /// **'Lote'**
  String get lote;

  /// No description provided for @fazenda.
  ///
  /// In pt, this message translates to:
  /// **'Fazenda'**
  String get fazenda;

  /// No description provided for @detalhes.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get detalhes;

  /// No description provided for @acessoAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Acesso Admin'**
  String get acessoAdmin;

  /// No description provided for @insiraEmailCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Insira o email para receber o código de acesso'**
  String get insiraEmailCodigo;

  /// No description provided for @emailAdmin.
  ///
  /// In pt, this message translates to:
  /// **'E-mail do administrador'**
  String get emailAdmin;

  /// No description provided for @emailHint.
  ///
  /// In pt, this message translates to:
  /// **'exemplo@email.com'**
  String get emailHint;

  /// No description provided for @enviarCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Enviar Código'**
  String get enviarCodigo;

  /// No description provided for @codigoEnviado.
  ///
  /// In pt, this message translates to:
  /// **'Código enviado para {email}'**
  String codigoEnviado(Object email);

  /// No description provided for @verifiqueCaixa.
  ///
  /// In pt, this message translates to:
  /// **'Verifique a sua caixa de entrada'**
  String get verifiqueCaixa;

  /// No description provided for @codigoVerificacao.
  ///
  /// In pt, this message translates to:
  /// **'Código de verificação'**
  String get codigoVerificacao;

  /// No description provided for @codigoHint.
  ///
  /// In pt, this message translates to:
  /// **'000000'**
  String get codigoHint;

  /// No description provided for @reenviarCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar código'**
  String get reenviarCodigo;

  /// No description provided for @verificarEntrar.
  ///
  /// In pt, this message translates to:
  /// **'Verificar e Entrar'**
  String get verificarEntrar;

  /// No description provided for @usarOutroEmail.
  ///
  /// In pt, this message translates to:
  /// **'Usar outro email'**
  String get usarOutroEmail;

  /// No description provided for @voltar.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get voltar;

  /// No description provided for @emailNaoEncontrado.
  ///
  /// In pt, this message translates to:
  /// **'Email não encontrado'**
  String get emailNaoEncontrado;

  /// No description provided for @semPermissoesAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Sem permissões de administrador'**
  String get semPermissoesAdmin;

  /// No description provided for @prepararAcessoErro.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível preparar o acesso. Contacte o suporte.'**
  String get prepararAcessoErro;

  /// No description provided for @erroEnvioEmail.
  ///
  /// In pt, this message translates to:
  /// **'Erro no envio de email. Contacte o suporte técnico.'**
  String get erroEnvioEmail;

  /// No description provided for @muitasTentativas.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Aguarde alguns minutos e tente novamente.'**
  String get muitasTentativas;

  /// No description provided for @erroEnvioCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar código. Verifique a sua ligação à internet.'**
  String get erroEnvioCodigo;

  /// No description provided for @codigoInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Código inválido ou expirado'**
  String get codigoInvalido;

  /// No description provided for @erroVerificarCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao verificar código. Tente novamente.'**
  String get erroVerificarCodigo;

  /// No description provided for @insiraEmail.
  ///
  /// In pt, this message translates to:
  /// **'Insira o seu e-mail'**
  String get insiraEmail;

  /// No description provided for @emailInvalido.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get emailInvalido;

  /// No description provided for @insiraCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Insira o código'**
  String get insiraCodigo;

  /// No description provided for @codigo6Digitos.
  ///
  /// In pt, this message translates to:
  /// **'Código deve ter 6 dígitos'**
  String get codigo6Digitos;

  /// No description provided for @venda.
  ///
  /// In pt, this message translates to:
  /// **'Venda'**
  String get venda;

  /// No description provided for @arrendamento.
  ///
  /// In pt, this message translates to:
  /// **'Arrendamento'**
  String get arrendamento;

  /// No description provided for @quartos.
  ///
  /// In pt, this message translates to:
  /// **'quartos'**
  String get quartos;

  /// No description provided for @casasDeBanho.
  ///
  /// In pt, this message translates to:
  /// **'Casas de Banho'**
  String get casasDeBanho;

  /// No description provided for @areaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Área'**
  String get areaLabel;

  /// No description provided for @areaM2.
  ///
  /// In pt, this message translates to:
  /// **'Área (m²)'**
  String get areaM2;

  /// No description provided for @detalhesImovel.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Imóvel'**
  String get detalhesImovel;

  /// No description provided for @detalhesTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Terreno'**
  String get detalhesTerreno;

  /// No description provided for @imovel.
  ///
  /// In pt, this message translates to:
  /// **'Imóvel'**
  String get imovel;

  /// No description provided for @descricao.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get descricao;

  /// No description provided for @caracteristicas.
  ///
  /// In pt, this message translates to:
  /// **'Características'**
  String get caracteristicas;

  /// No description provided for @localizacao.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get localizacao;

  /// No description provided for @municipio.
  ///
  /// In pt, this message translates to:
  /// **'Município'**
  String get municipio;

  /// No description provided for @endereco.
  ///
  /// In pt, this message translates to:
  /// **'Endereço'**
  String get endereco;

  /// No description provided for @precoAOA.
  ///
  /// In pt, this message translates to:
  /// **'Preço (Kz)'**
  String get precoAOA;

  /// No description provided for @tipoTransacao.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de Transação'**
  String get tipoTransacao;

  /// No description provided for @transacao.
  ///
  /// In pt, this message translates to:
  /// **'Transação'**
  String get transacao;

  /// No description provided for @tipoImovel.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de Imóvel'**
  String get tipoImovel;

  /// No description provided for @casa.
  ///
  /// In pt, this message translates to:
  /// **'Casa'**
  String get casa;

  /// No description provided for @apartamento.
  ///
  /// In pt, this message translates to:
  /// **'Apartamento'**
  String get apartamento;

  /// No description provided for @terreno.
  ///
  /// In pt, this message translates to:
  /// **'Terreno'**
  String get terreno;

  /// No description provided for @escritorio.
  ///
  /// In pt, this message translates to:
  /// **'Escritório'**
  String get escritorio;

  /// No description provided for @escritorios.
  ///
  /// In pt, this message translates to:
  /// **'Escritórios'**
  String get escritorios;

  /// No description provided for @loja.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get loja;

  /// No description provided for @condominio.
  ///
  /// In pt, this message translates to:
  /// **'Condomínio'**
  String get condominio;

  /// No description provided for @condominios.
  ///
  /// In pt, this message translates to:
  /// **'Condomínios'**
  String get condominios;

  /// No description provided for @armazem.
  ///
  /// In pt, this message translates to:
  /// **'Armazém'**
  String get armazem;

  /// No description provided for @imovelNaoEncontrado.
  ///
  /// In pt, this message translates to:
  /// **'Imóvel não encontrado'**
  String get imovelNaoEncontrado;

  /// No description provided for @terrenoNaoEncontrado.
  ///
  /// In pt, this message translates to:
  /// **'Terreno não encontrado'**
  String get terrenoNaoEncontrado;

  /// No description provided for @naoInformado.
  ///
  /// In pt, this message translates to:
  /// **'Não informado'**
  String get naoInformado;

  /// No description provided for @naoEncontrado.
  ///
  /// In pt, this message translates to:
  /// **'Não encontrado'**
  String get naoEncontrado;

  /// No description provided for @coordenadasIndisponiveis.
  ///
  /// In pt, this message translates to:
  /// **'Coordenadas indisponíveis'**
  String get coordenadasIndisponiveis;

  /// No description provided for @comprar.
  ///
  /// In pt, this message translates to:
  /// **'Comprar'**
  String get comprar;

  /// No description provided for @agendarVisita.
  ///
  /// In pt, this message translates to:
  /// **'Agendar Visita'**
  String get agendarVisita;

  /// No description provided for @verEmLuar.
  ///
  /// In pt, this message translates to:
  /// **'Ver em Luar Mobiliario'**
  String get verEmLuar;

  /// No description provided for @tipoTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de Terreno'**
  String get tipoTerreno;

  /// No description provided for @areaTotal.
  ///
  /// In pt, this message translates to:
  /// **'Área Total'**
  String get areaTotal;

  /// No description provided for @dimensoes.
  ///
  /// In pt, this message translates to:
  /// **'Dimensões'**
  String get dimensoes;

  /// No description provided for @agua.
  ///
  /// In pt, this message translates to:
  /// **'Água'**
  String get agua;

  /// No description provided for @poco.
  ///
  /// In pt, this message translates to:
  /// **'Poço'**
  String get poco;

  /// No description provided for @soloFertil.
  ///
  /// In pt, this message translates to:
  /// **'Solo Fértil'**
  String get soloFertil;

  /// No description provided for @inclinacaoSuave.
  ///
  /// In pt, this message translates to:
  /// **'Inclinação Suave'**
  String get inclinacaoSuave;

  /// No description provided for @estradaAcessivel.
  ///
  /// In pt, this message translates to:
  /// **'Estrada Acessível'**
  String get estradaAcessivel;

  /// No description provided for @portaoEletronico.
  ///
  /// In pt, this message translates to:
  /// **'Portão Eletrónico'**
  String get portaoEletronico;

  /// No description provided for @tanqueAgua.
  ///
  /// In pt, this message translates to:
  /// **'Tanque de Água'**
  String get tanqueAgua;

  /// No description provided for @condominioFechado.
  ///
  /// In pt, this message translates to:
  /// **'Condomínio Fechado'**
  String get condominioFechado;

  /// No description provided for @seguranca24h.
  ///
  /// In pt, this message translates to:
  /// **'Segurança 24h'**
  String get seguranca24h;

  /// No description provided for @vistaPanoramica.
  ///
  /// In pt, this message translates to:
  /// **'Vista Panorâmica'**
  String get vistaPanoramica;

  /// No description provided for @areaServico.
  ///
  /// In pt, this message translates to:
  /// **'Área de Serviço'**
  String get areaServico;

  /// No description provided for @varandaGourmet.
  ///
  /// In pt, this message translates to:
  /// **'Varanda Gourmet'**
  String get varandaGourmet;

  /// No description provided for @suite.
  ///
  /// In pt, this message translates to:
  /// **'Suíte'**
  String get suite;

  /// No description provided for @arvoreFrutifera.
  ///
  /// In pt, this message translates to:
  /// **'Árvore Frutífera'**
  String get arvoreFrutifera;

  /// No description provided for @closePraia.
  ///
  /// In pt, this message translates to:
  /// **'Close à Praia'**
  String get closePraia;

  /// No description provided for @arCondicionado.
  ///
  /// In pt, this message translates to:
  /// **'Ar Condicionado'**
  String get arCondicionado;

  /// No description provided for @pesquisarImoveis.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar imóveis...'**
  String get pesquisarImoveis;

  /// No description provided for @pesquisarTerrenos.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar terrenos...'**
  String get pesquisarTerrenos;

  /// No description provided for @pesquisarTudo.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar imóveis e terrenos...'**
  String get pesquisarTudo;

  /// No description provided for @semResultados.
  ///
  /// In pt, this message translates to:
  /// **'Sem resultados'**
  String get semResultados;

  /// No description provided for @nenhumResultado.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado encontrado'**
  String get nenhumResultado;

  /// No description provided for @nenhumImovelEncontrado.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum imóvel encontrado'**
  String get nenhumImovelEncontrado;

  /// No description provided for @nenhumTerrenoEncontrado.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum terreno encontrado'**
  String get nenhumTerrenoEncontrado;

  /// No description provided for @nenhumImovelBusca.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum imóvel encontrado para \"{q}\"'**
  String nenhumImovelBusca(Object q);

  /// No description provided for @nenhumTerrenoBusca.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum terreno encontrado para \"{q}\"'**
  String nenhumTerrenoBusca(Object q);

  /// No description provided for @sicategoria.
  ///
  /// In pt, this message translates to:
  /// **'Não encontrámos imóveis nesta categoria. Tente outro filtro.'**
  String get sicategoria;

  /// No description provided for @terrenoCategoriaVazio.
  ///
  /// In pt, this message translates to:
  /// **'Não encontrámos terrenos nesta categoria. Tente outro filtro.'**
  String get terrenoCategoriaVazio;

  /// No description provided for @ajustarFiltros.
  ///
  /// In pt, this message translates to:
  /// **'Tente ajustar os filtros ou pesquisar por outro termo.'**
  String get ajustarFiltros;

  /// No description provided for @aplicarFiltros.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar Filtros'**
  String get aplicarFiltros;

  /// No description provided for @limparTudo.
  ///
  /// In pt, this message translates to:
  /// **'Limpar tudo'**
  String get limparTudo;

  /// No description provided for @faixaPreco.
  ///
  /// In pt, this message translates to:
  /// **'Faixa de Preço'**
  String get faixaPreco;

  /// No description provided for @maiorArea.
  ///
  /// In pt, this message translates to:
  /// **'Maior área'**
  String get maiorArea;

  /// No description provided for @menorPreco.
  ///
  /// In pt, this message translates to:
  /// **'Menor preço'**
  String get menorPreco;

  /// No description provided for @maiorPreco.
  ///
  /// In pt, this message translates to:
  /// **'Maior preço'**
  String get maiorPreco;

  /// No description provided for @maisRecentes.
  ///
  /// In pt, this message translates to:
  /// **'Mais recentes'**
  String get maisRecentes;

  /// No description provided for @proximas.
  ///
  /// In pt, this message translates to:
  /// **'Próximas'**
  String get proximas;

  /// No description provided for @historico.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get historico;

  /// No description provided for @todosImoveisCarregados.
  ///
  /// In pt, this message translates to:
  /// **'Todos os imóveis carregados'**
  String get todosImoveisCarregados;

  /// No description provided for @todosTerrenosCarregados.
  ///
  /// In pt, this message translates to:
  /// **'Todos os terrenos carregados'**
  String get todosTerrenosCarregados;

  /// No description provided for @maxPreco.
  ///
  /// In pt, this message translates to:
  /// **'Máx: Kz {v}'**
  String maxPreco(Object v);

  /// No description provided for @minPreco.
  ///
  /// In pt, this message translates to:
  /// **'Mín: Kz {v}'**
  String minPreco(Object v);

  /// No description provided for @selecioneCidade.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a cidade'**
  String get selecioneCidade;

  /// No description provided for @provincia.
  ///
  /// In pt, this message translates to:
  /// **'Província'**
  String get provincia;

  /// No description provided for @selecioneProvincia.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a província'**
  String get selecioneProvincia;

  /// No description provided for @cidadeLuandaNorte.
  ///
  /// In pt, this message translates to:
  /// **'Luanda Norte'**
  String get cidadeLuandaNorte;

  /// No description provided for @icoloBengo.
  ///
  /// In pt, this message translates to:
  /// **'Icolo e Bengo'**
  String get icoloBengo;

  /// No description provided for @bie.
  ///
  /// In pt, this message translates to:
  /// **'Bié'**
  String get bie;

  /// No description provided for @cuanzaNorte.
  ///
  /// In pt, this message translates to:
  /// **'Cuanza Norte'**
  String get cuanzaNorte;

  /// No description provided for @cuanzaSul.
  ///
  /// In pt, this message translates to:
  /// **'Cuanza Sul'**
  String get cuanzaSul;

  /// No description provided for @huila.
  ///
  /// In pt, this message translates to:
  /// **'Huíla'**
  String get huila;

  /// No description provided for @lundaNorte.
  ///
  /// In pt, this message translates to:
  /// **'Lunda Norte'**
  String get lundaNorte;

  /// No description provided for @lundaSul.
  ///
  /// In pt, this message translates to:
  /// **'Lunda Sul'**
  String get lundaSul;

  /// No description provided for @uige.
  ///
  /// In pt, this message translates to:
  /// **'Uíge'**
  String get uige;

  /// No description provided for @ruaNumero.
  ///
  /// In pt, this message translates to:
  /// **'Rua, número...'**
  String get ruaNumero;

  /// No description provided for @ruaNumeroMunicipio.
  ///
  /// In pt, this message translates to:
  /// **'Rua, número, município...'**
  String get ruaNumeroMunicipio;

  /// No description provided for @semFavoritos.
  ///
  /// In pt, this message translates to:
  /// **'Sem favoritos'**
  String get semFavoritos;

  /// No description provided for @adicioneImoveisFavoritos.
  ///
  /// In pt, this message translates to:
  /// **'Adicione imóveis aos seus favoritos para vê-los aqui.'**
  String get adicioneImoveisFavoritos;

  /// No description provided for @adicioneTerrenosFavoritos.
  ///
  /// In pt, this message translates to:
  /// **'Adicione terrenos aos seus favoritos para vê-los aqui.'**
  String get adicioneTerrenosFavoritos;

  /// No description provided for @favoritosDisponiveisConta.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos disponíveis com conta'**
  String get favoritosDisponiveisConta;

  /// No description provided for @guardeImoveisConta.
  ///
  /// In pt, this message translates to:
  /// **'Guarde os imóveis e terrenos preferidos depois de criar a sua conta ao agendar uma visita.'**
  String get guardeImoveisConta;

  /// No description provided for @removerImovel.
  ///
  /// In pt, this message translates to:
  /// **'Remover Imóvel'**
  String get removerImovel;

  /// No description provided for @removerTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Remover Terreno'**
  String get removerTerreno;

  /// No description provided for @desejaRemoverImovel.
  ///
  /// In pt, this message translates to:
  /// **'Deseja remover \"{title}\"? Esta ação pode ser desfeita.'**
  String desejaRemoverImovel(Object title);

  /// No description provided for @desejaRemoverTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Deseja remover \"{title}\"? Esta ação pode ser desfeita.'**
  String desejaRemoverTerreno(Object title);

  /// No description provided for @semAgendamentos.
  ///
  /// In pt, this message translates to:
  /// **'Sem agendamentos'**
  String get semAgendamentos;

  /// No description provided for @seuProximoAgendamento.
  ///
  /// In pt, this message translates to:
  /// **'Seus próximos agendamentos aparecerão aqui.'**
  String get seuProximoAgendamento;

  /// No description provided for @agendamentosAnteriores.
  ///
  /// In pt, this message translates to:
  /// **'Agendamentos anteriores aparecerão aqui.'**
  String get agendamentosAnteriores;

  /// No description provided for @cancelarAgendamento.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar Agendamento'**
  String get cancelarAgendamento;

  /// No description provided for @confirmarAgendamento.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Agendamento'**
  String get confirmarAgendamento;

  /// No description provided for @simCancelar.
  ///
  /// In pt, this message translates to:
  /// **'Sim, Cancelar'**
  String get simCancelar;

  /// No description provided for @nao.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get nao;

  /// No description provided for @cancelar.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @remover.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get remover;

  /// No description provided for @desejaCancelarAgendamento.
  ///
  /// In pt, this message translates to:
  /// **'Deseja cancelar o agendamento para \"{title}\"?'**
  String desejaCancelarAgendamento(Object title);

  /// No description provided for @agendamentoSolicitado.
  ///
  /// In pt, this message translates to:
  /// **'Agendamento solicitado com sucesso!'**
  String get agendamentoSolicitado;

  /// No description provided for @agendamentoRegistado.
  ///
  /// In pt, this message translates to:
  /// **'Agendamento registado com sucesso!'**
  String get agendamentoRegistado;

  /// No description provided for @erroCriarAgendamento.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao criar agendamento. Tente novamente.'**
  String get erroCriarAgendamento;

  /// No description provided for @agendamentoAtualizado.
  ///
  /// In pt, this message translates to:
  /// **'Agendamento atualizado com sucesso!'**
  String get agendamentoAtualizado;

  /// No description provided for @erroAtualizarDados.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao atualizar. Tente novamente.'**
  String get erroAtualizarDados;

  /// No description provided for @agendadoPor.
  ///
  /// In pt, this message translates to:
  /// **'Agendado por: {name}'**
  String agendadoPor(Object name);

  /// No description provided for @quandoAgenda.
  ///
  /// In pt, this message translates to:
  /// **'Quando agenda uma visita, os seus agendamentos passam a ficar disponíveis aqui.'**
  String get quandoAgenda;

  /// No description provided for @osSeusAgendamentos.
  ///
  /// In pt, this message translates to:
  /// **'Os seus agendamentos'**
  String get osSeusAgendamentos;

  /// No description provided for @carregandoAgendamentos.
  ///
  /// In pt, this message translates to:
  /// **'Carregando agendamentos...'**
  String get carregandoAgendamentos;

  /// No description provided for @imovelCurto.
  ///
  /// In pt, this message translates to:
  /// **'Imóvel #{id}'**
  String imovelCurto(Object id);

  /// No description provided for @completeRegisto.
  ///
  /// In pt, this message translates to:
  /// **'Complete o registo'**
  String get completeRegisto;

  /// No description provided for @indiqueNomeTelefone.
  ///
  /// In pt, this message translates to:
  /// **'Indique apenas o seu nome e telefone para ficar registado.'**
  String get indiqueNomeTelefone;

  /// No description provided for @nomeCompleto.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get nomeCompleto;

  /// No description provided for @oSeuNome.
  ///
  /// In pt, this message translates to:
  /// **'O seu nome'**
  String get oSeuNome;

  /// No description provided for @erroRegistarDados.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao registar os seus dados. Tente novamente.'**
  String get erroRegistarDados;

  /// No description provided for @insiraNome.
  ///
  /// In pt, this message translates to:
  /// **'Insira o seu nome'**
  String get insiraNome;

  /// No description provided for @concluir.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get concluir;

  /// No description provided for @falarWhatsapp.
  ///
  /// In pt, this message translates to:
  /// **'Falar no WhatsApp'**
  String get falarWhatsapp;

  /// No description provided for @concluirRegisto.
  ///
  /// In pt, this message translates to:
  /// **'Concluir Registo'**
  String get concluirRegisto;

  /// No description provided for @dadosRegistados.
  ///
  /// In pt, this message translates to:
  /// **'Os seus dados são registados'**
  String get dadosRegistados;

  /// No description provided for @aoAgendarFicaRegistado.
  ///
  /// In pt, this message translates to:
  /// **'Ao agendar uma visita a um dos nossos imóveis, fica automaticamente registado com o seu nome e telefone.'**
  String get aoAgendarFicaRegistado;

  /// No description provided for @naoInformadoPhone.
  ///
  /// In pt, this message translates to:
  /// **'Não informado'**
  String get naoInformadoPhone;

  /// No description provided for @semMensagens.
  ///
  /// In pt, this message translates to:
  /// **'Sem mensagens'**
  String get semMensagens;

  /// No description provided for @mensagensDisponiveisConta.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens disponíveis com conta'**
  String get mensagensDisponiveisConta;

  /// No description provided for @converseCorretores.
  ///
  /// In pt, this message translates to:
  /// **'Converse com corretores e vendedores depois de criar a sua conta ao agendar uma visita.'**
  String get converseCorretores;

  /// No description provided for @suasConversas.
  ///
  /// In pt, this message translates to:
  /// **'Suas conversas com corretores e vendedores aparecerão aqui.'**
  String get suasConversas;

  /// No description provided for @inicieConversa.
  ///
  /// In pt, this message translates to:
  /// **'Inicie a conversa'**
  String get inicieConversa;

  /// No description provided for @envieMensagem.
  ///
  /// In pt, this message translates to:
  /// **'Envie uma mensagem para começar'**
  String get envieMensagem;

  /// No description provided for @escrevaMensagem.
  ///
  /// In pt, this message translates to:
  /// **'Escreva uma mensagem...'**
  String get escrevaMensagem;

  /// No description provided for @carregandoMensagens.
  ///
  /// In pt, this message translates to:
  /// **'Carregando mensagens...'**
  String get carregandoMensagens;

  /// No description provided for @mensagensNaoLidas.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens Não Lidas'**
  String get mensagensNaoLidas;

  /// No description provided for @meuPerfil.
  ///
  /// In pt, this message translates to:
  /// **'Meu Perfil'**
  String get meuPerfil;

  /// No description provided for @sair.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get sair;

  /// No description provided for @sairDaConta.
  ///
  /// In pt, this message translates to:
  /// **'Sair da Conta'**
  String get sairDaConta;

  /// No description provided for @temCertezaSair.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja sair?'**
  String get temCertezaSair;

  /// No description provided for @editarPerfil.
  ///
  /// In pt, this message translates to:
  /// **'Editar Perfil'**
  String get editarPerfil;

  /// No description provided for @agendamentos.
  ///
  /// In pt, this message translates to:
  /// **'Agendamentos'**
  String get agendamentos;

  /// No description provided for @mensagens.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens'**
  String get mensagens;

  /// No description provided for @parceiros.
  ///
  /// In pt, this message translates to:
  /// **'Parceiros'**
  String get parceiros;

  /// No description provided for @utilizador.
  ///
  /// In pt, this message translates to:
  /// **'Utilizador'**
  String get utilizador;

  /// No description provided for @admin.
  ///
  /// In pt, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @agente.
  ///
  /// In pt, this message translates to:
  /// **'Agente'**
  String get agente;

  /// No description provided for @cliente.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get cliente;

  /// No description provided for @perfilAtualizado.
  ///
  /// In pt, this message translates to:
  /// **'Perfil atualizado com sucesso!'**
  String get perfilAtualizado;

  /// No description provided for @guadarPerfil.
  ///
  /// In pt, this message translates to:
  /// **'Guardar Perfil'**
  String get guadarPerfil;

  /// No description provided for @guardarAlteracoes.
  ///
  /// In pt, this message translates to:
  /// **'Guardar Alterações'**
  String get guardarAlteracoes;

  /// No description provided for @erroAoGuardar.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao guardar'**
  String get erroAoGuardar;

  /// No description provided for @erroAoCarregar.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar'**
  String get erroAoCarregar;

  /// No description provided for @naoFoiPossivelCarregar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar'**
  String get naoFoiPossivelCarregar;

  /// No description provided for @tentarNovamente.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tentarNovamente;

  /// No description provided for @ordenar.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar'**
  String get ordenar;

  /// No description provided for @aplicar.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get aplicar;

  /// No description provided for @eliminar.
  ///
  /// In pt, this message translates to:
  /// **'Eliminar'**
  String get eliminar;

  /// No description provided for @mapa.
  ///
  /// In pt, this message translates to:
  /// **'Mapa'**
  String get mapa;

  /// No description provided for @preVisualizar.
  ///
  /// In pt, this message translates to:
  /// **'Pré-visualizar'**
  String get preVisualizar;

  /// No description provided for @guardarPesquisa.
  ///
  /// In pt, this message translates to:
  /// **'Guardar pesquisa'**
  String get guardarPesquisa;

  /// No description provided for @pesquisasGuardadas.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisas guardadas'**
  String get pesquisasGuardadas;

  /// No description provided for @pesquisaGuardadaComSucesso.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisa guardada com sucesso'**
  String get pesquisaGuardadaComSucesso;

  /// No description provided for @nomePesquisa.
  ///
  /// In pt, this message translates to:
  /// **'Nome da pesquisa'**
  String get nomePesquisa;

  /// No description provided for @recomendados.
  ///
  /// In pt, this message translates to:
  /// **'Recomendados para si'**
  String get recomendados;

  /// No description provided for @semPesquisasGuardadas.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tem pesquisas guardadas'**
  String get semPesquisasGuardadas;

  /// No description provided for @semMapaDisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Sem localização disponível para o mapa'**
  String get semMapaDisponivel;

  /// No description provided for @erroAoCarregarMapa.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar o mapa'**
  String get erroAoCarregarMapa;

  /// No description provided for @enviarImagemDe.
  ///
  /// In pt, this message translates to:
  /// **'A enviar imagem {atual} de {total}'**
  String enviarImagemDe(Object atual, Object total);

  /// No description provided for @algoCorreuMal.
  ///
  /// In pt, this message translates to:
  /// **'Algo correu mal'**
  String get algoCorreuMal;

  /// No description provided for @erroDesconhecido.
  ///
  /// In pt, this message translates to:
  /// **'Erro desconhecido'**
  String get erroDesconhecido;

  /// No description provided for @registadoEm.
  ///
  /// In pt, this message translates to:
  /// **'Registado em'**
  String get registadoEm;

  /// No description provided for @concluida.
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get concluida;

  /// No description provided for @agenteImobiliario.
  ///
  /// In pt, this message translates to:
  /// **'Agente Imobiliário'**
  String get agenteImobiliario;

  /// No description provided for @administrador.
  ///
  /// In pt, this message translates to:
  /// **'Administrador'**
  String get administrador;

  /// No description provided for @aparencia.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get aparencia;

  /// No description provided for @tema.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get tema;

  /// No description provided for @temaSistema.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get temaSistema;

  /// No description provided for @temaClaro.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get temaClaro;

  /// No description provided for @temaEscuro.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get temaEscuro;

  /// No description provided for @idioma.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @portugues.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portugues;

  /// No description provided for @ingles.
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get ingles;

  /// No description provided for @telefone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get telefone;

  /// No description provided for @nome.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get nome;

  /// No description provided for @avatar.
  ///
  /// In pt, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @perfilParceiro.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de Parceiro'**
  String get perfilParceiro;

  /// No description provided for @nomeEmpresa.
  ///
  /// In pt, this message translates to:
  /// **'Nome da Empresa'**
  String get nomeEmpresa;

  /// No description provided for @tipoNegocio.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de Negócio'**
  String get tipoNegocio;

  /// No description provided for @nif.
  ///
  /// In pt, this message translates to:
  /// **'NIF: {nif}'**
  String nif(Object nif);

  /// No description provided for @whatsapp.
  ///
  /// In pt, this message translates to:
  /// **'WhatsApp: {wa}'**
  String whatsapp(Object wa);

  /// No description provided for @licenca.
  ///
  /// In pt, this message translates to:
  /// **'Licença'**
  String get licenca;

  /// No description provided for @numeroLicenca.
  ///
  /// In pt, this message translates to:
  /// **'Número da licença de corretor (opcional)'**
  String get numeroLicenca;

  /// No description provided for @dadosEmpresa.
  ///
  /// In pt, this message translates to:
  /// **'Dados da Empresa'**
  String get dadosEmpresa;

  /// No description provided for @exNomeEmpresa.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Luar Imobiliária Lda'**
  String get exNomeEmpresa;

  /// No description provided for @meuPerfilParceiro.
  ///
  /// In pt, this message translates to:
  /// **'Meu perfil de parceiro'**
  String get meuPerfilParceiro;

  /// No description provided for @perfilParceiroSalvo.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de parceiro salvo com sucesso!'**
  String get perfilParceiroSalvo;

  /// No description provided for @nenhumParceiro.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum parceiro encontrado'**
  String get nenhumParceiro;

  /// No description provided for @osParceirosAqui.
  ///
  /// In pt, this message translates to:
  /// **'Os parceiros da Luar Mobiliário aparecerão aqui.'**
  String get osParceirosAqui;

  /// No description provided for @carregandoParceiros.
  ///
  /// In pt, this message translates to:
  /// **'Carregando parceiros...'**
  String get carregandoParceiros;

  /// No description provided for @semParceiros.
  ///
  /// In pt, this message translates to:
  /// **'Sem parceiros'**
  String get semParceiros;

  /// No description provided for @observacoes.
  ///
  /// In pt, this message translates to:
  /// **'Observações (opcional)'**
  String get observacoes;

  /// No description provided for @contacto.
  ///
  /// In pt, this message translates to:
  /// **'Contacto'**
  String get contacto;

  /// No description provided for @criarImovel.
  ///
  /// In pt, this message translates to:
  /// **'Criar Imóvel'**
  String get criarImovel;

  /// No description provided for @criarTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Criar Terreno'**
  String get criarTerreno;

  /// No description provided for @editarImovel.
  ///
  /// In pt, this message translates to:
  /// **'Editar Imóvel'**
  String get editarImovel;

  /// No description provided for @editarTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Editar Terreno'**
  String get editarTerreno;

  /// No description provided for @atualizarImovel.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar Imóvel'**
  String get atualizarImovel;

  /// No description provided for @atualizarTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar Terreno'**
  String get atualizarTerreno;

  /// No description provided for @novoImovel.
  ///
  /// In pt, this message translates to:
  /// **'Novo Imóvel'**
  String get novoImovel;

  /// No description provided for @novoTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Novo Terreno'**
  String get novoTerreno;

  /// No description provided for @informacoesBasicas.
  ///
  /// In pt, this message translates to:
  /// **'Informações Básicas'**
  String get informacoesBasicas;

  /// No description provided for @titulo.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get titulo;

  /// No description provided for @addImg.
  ///
  /// In pt, this message translates to:
  /// **'Adicione pelo menos uma imagem'**
  String get addImg;

  /// No description provided for @nenhumaImagemSelecionada.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma imagem selecionada'**
  String get nenhumaImagemSelecionada;

  /// No description provided for @exTituloImovel.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Apartamento T3 na Talatona'**
  String get exTituloImovel;

  /// No description provided for @exTituloTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Terreno Urbano na Talatona'**
  String get exTituloTerreno;

  /// No description provided for @descrevaImovel.
  ///
  /// In pt, this message translates to:
  /// **'Descreva o imóvel...'**
  String get descrevaImovel;

  /// No description provided for @descrevaTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Descreva o terreno...'**
  String get descrevaTerreno;

  /// No description provided for @obrigatorio.
  ///
  /// In pt, this message translates to:
  /// **'Obrigatório'**
  String get obrigatorio;

  /// No description provided for @imovelCriado.
  ///
  /// In pt, this message translates to:
  /// **'Imóvel criado!'**
  String get imovelCriado;

  /// No description provided for @imovelAtualizado.
  ///
  /// In pt, this message translates to:
  /// **'Imóvel atualizado!'**
  String get imovelAtualizado;

  /// No description provided for @terrenoCriado.
  ///
  /// In pt, this message translates to:
  /// **'Terreno criado!'**
  String get terrenoCriado;

  /// No description provided for @terrenoAtualizado.
  ///
  /// In pt, this message translates to:
  /// **'Terreno atualizado!'**
  String get terrenoAtualizado;

  /// No description provided for @garagem.
  ///
  /// In pt, this message translates to:
  /// **'garagem'**
  String get garagem;

  /// No description provided for @wc.
  ///
  /// In pt, this message translates to:
  /// **'WC'**
  String get wc;

  /// No description provided for @fichaTecnica.
  ///
  /// In pt, this message translates to:
  /// **'Ficha Técnica'**
  String get fichaTecnica;

  /// No description provided for @caracteristicaSolo.
  ///
  /// In pt, this message translates to:
  /// **'Características do Solo'**
  String get caracteristicaSolo;

  /// No description provided for @areaTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Área (m²)'**
  String get areaTerreno;

  /// No description provided for @preco.
  ///
  /// In pt, this message translates to:
  /// **'Preço (Kz)'**
  String get preco;

  /// No description provided for @telefoneContato.
  ///
  /// In pt, this message translates to:
  /// **'Telefone de contato'**
  String get telefoneContato;

  /// No description provided for @whatsappContato.
  ///
  /// In pt, this message translates to:
  /// **'WhatsApp de contato'**
  String get whatsappContato;

  /// No description provided for @nifLabel.
  ///
  /// In pt, this message translates to:
  /// **'NIF'**
  String get nifLabel;

  /// No description provided for @licencaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Licença'**
  String get licencaLabel;

  /// No description provided for @piso.
  ///
  /// In pt, this message translates to:
  /// **'Piso'**
  String get piso;

  /// No description provided for @quartosLabel.
  ///
  /// In pt, this message translates to:
  /// **'Quartos'**
  String get quartosLabel;

  /// No description provided for @casasDeBanhoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Casas de Banho'**
  String get casasDeBanhoLabel;

  /// No description provided for @areasComuns.
  ///
  /// In pt, this message translates to:
  /// **'Áreas Comuns'**
  String get areasComuns;

  /// No description provided for @estacionamento.
  ///
  /// In pt, this message translates to:
  /// **'Estacionamento'**
  String get estacionamento;

  /// No description provided for @conservacao.
  ///
  /// In pt, this message translates to:
  /// **'Estado de Conservação'**
  String get conservacao;

  /// No description provided for @novo.
  ///
  /// In pt, this message translates to:
  /// **'Novo'**
  String get novo;

  /// No description provided for @usado.
  ///
  /// In pt, this message translates to:
  /// **'Usado'**
  String get usado;

  /// No description provided for @emConstrucao.
  ///
  /// In pt, this message translates to:
  /// **'Em construção'**
  String get emConstrucao;

  /// No description provided for @precoM2.
  ///
  /// In pt, this message translates to:
  /// **'Preço (Kz/m²)'**
  String get precoM2;

  /// No description provided for @longitude.
  ///
  /// In pt, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @latitude.
  ///
  /// In pt, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @painelAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Painel Admin'**
  String get painelAdmin;

  /// No description provided for @visaoGeral.
  ///
  /// In pt, this message translates to:
  /// **'Visão Geral'**
  String get visaoGeral;

  /// No description provided for @totalImoveis.
  ///
  /// In pt, this message translates to:
  /// **'Total Imóveis'**
  String get totalImoveis;

  /// No description provided for @totalTerrenos.
  ///
  /// In pt, this message translates to:
  /// **'Total Terrenos'**
  String get totalTerrenos;

  /// No description provided for @totalUtilizadores.
  ///
  /// In pt, this message translates to:
  /// **'Total Utilizadores'**
  String get totalUtilizadores;

  /// No description provided for @acoesRapidas.
  ///
  /// In pt, this message translates to:
  /// **'Ações Rápidas'**
  String get acoesRapidas;

  /// No description provided for @gerirImoveis.
  ///
  /// In pt, this message translates to:
  /// **'Gerir Imóveis'**
  String get gerirImoveis;

  /// No description provided for @gerirTerrenos.
  ///
  /// In pt, this message translates to:
  /// **'Gerir Terrenos'**
  String get gerirTerrenos;

  /// No description provided for @gerirUtilizadores.
  ///
  /// In pt, this message translates to:
  /// **'Gerir Utilizadores'**
  String get gerirUtilizadores;

  /// No description provided for @gerir.
  ///
  /// In pt, this message translates to:
  /// **'Gerir\nImóveis'**
  String get gerir;

  /// No description provided for @verParceiros.
  ///
  /// In pt, this message translates to:
  /// **'Ver\nParceiros'**
  String get verParceiros;

  /// No description provided for @verUtilizadores.
  ///
  /// In pt, this message translates to:
  /// **'Ver\nUtilizadores'**
  String get verUtilizadores;

  /// No description provided for @cadastroImovel.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar\nImóvel'**
  String get cadastroImovel;

  /// No description provided for @cadastroTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar\nTerreno'**
  String get cadastroTerreno;

  /// No description provided for @totalMensagens.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens Não Lidas'**
  String get totalMensagens;

  /// No description provided for @semImoveis.
  ///
  /// In pt, this message translates to:
  /// **'Sem imóveis'**
  String get semImoveis;

  /// No description provided for @semTerrenos.
  ///
  /// In pt, this message translates to:
  /// **'Sem terrenos'**
  String get semTerrenos;

  /// No description provided for @erroRemoverUtilizador.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao remover utilizador'**
  String get erroRemoverUtilizador;

  /// No description provided for @utilizadorRemovido.
  ///
  /// In pt, this message translates to:
  /// **'Utilizador removido'**
  String get utilizadorRemovido;

  /// No description provided for @removerUtilizador.
  ///
  /// In pt, this message translates to:
  /// **'Remover utilizador'**
  String get removerUtilizador;

  /// No description provided for @temCertezaRemover.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja remover {name}? Esta ação não pode ser desfeita.'**
  String temCertezaRemover(Object name);

  /// No description provided for @acaoIrreversivel.
  ///
  /// In pt, this message translates to:
  /// **'Ação irreversível'**
  String get acaoIrreversivel;

  /// No description provided for @alterarFuncao.
  ///
  /// In pt, this message translates to:
  /// **'Alterar função'**
  String get alterarFuncao;

  /// No description provided for @alterarFuncaoDe.
  ///
  /// In pt, this message translates to:
  /// **'Alterar a função de {name} para \"{role}\"?'**
  String alterarFuncaoDe(Object name, Object role);

  /// No description provided for @funcaoAlterada.
  ///
  /// In pt, this message translates to:
  /// **'Função alterada para {role}'**
  String funcaoAlterada(Object role);

  /// No description provided for @erroAlterarFuncao.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao alterar função'**
  String get erroAlterarFuncao;

  /// No description provided for @funcao.
  ///
  /// In pt, this message translates to:
  /// **'Função'**
  String get funcao;

  /// No description provided for @nenhumUtilizador.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum utilizador registado.'**
  String get nenhumUtilizador;

  /// No description provided for @nenhumUtilizadorBusca.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum utilizador encontrado para \"{q}\"'**
  String nenhumUtilizadorBusca(Object q);

  /// No description provided for @pesquisarUtilizadores.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar utilizadores...'**
  String get pesquisarUtilizadores;

  /// No description provided for @imoveis.
  ///
  /// In pt, this message translates to:
  /// **'Imóveis'**
  String get imoveis;

  /// No description provided for @imoveisCount.
  ///
  /// In pt, this message translates to:
  /// **'Imóveis ({count})'**
  String imoveisCount(Object count);

  /// No description provided for @terrenosCount.
  ///
  /// In pt, this message translates to:
  /// **'Terrenos ({count})'**
  String terrenosCount(Object count);

  /// No description provided for @cadastrePrimeiroImovel.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre o primeiro imóvel utilizando o botão abaixo.'**
  String get cadastrePrimeiroImovel;

  /// No description provided for @cadastrePrimeiroTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre o primeiro terreno utilizando o botão abaixo.'**
  String get cadastrePrimeiroTerreno;

  /// No description provided for @carregandoImoveis.
  ///
  /// In pt, this message translates to:
  /// **'Carregando imóveis...'**
  String get carregandoImoveis;

  /// No description provided for @carregandoTerrenos.
  ///
  /// In pt, this message translates to:
  /// **'Carregando terrenos...'**
  String get carregandoTerrenos;

  /// No description provided for @carregandoImovel.
  ///
  /// In pt, this message translates to:
  /// **'Carregando imóvel...'**
  String get carregandoImovel;

  /// No description provided for @carregandoTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Carregando terreno...'**
  String get carregandoTerreno;

  /// No description provided for @carregandoFavoritos.
  ///
  /// In pt, this message translates to:
  /// **'Carregando favoritos...'**
  String get carregandoFavoritos;

  /// No description provided for @acessoRestritoAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Acesso restrito a administradores'**
  String get acessoRestritoAdmin;

  /// No description provided for @acessoRestritoAgentes.
  ///
  /// In pt, this message translates to:
  /// **'Acesso restrito a agentes e administradores'**
  String get acessoRestritoAgentes;

  /// No description provided for @sessaoExpirada.
  ///
  /// In pt, this message translates to:
  /// **'Sessão expirada. Entre novamente.'**
  String get sessaoExpirada;

  /// No description provided for @campoObrigatorio.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get campoObrigatorio;

  /// No description provided for @emailObrigatorio.
  ///
  /// In pt, this message translates to:
  /// **'Email obrigatório'**
  String get emailObrigatorio;

  /// No description provided for @emailInvalidoMsg.
  ///
  /// In pt, this message translates to:
  /// **'Email inválido'**
  String get emailInvalidoMsg;

  /// No description provided for @telefoneObrigatorio.
  ///
  /// In pt, this message translates to:
  /// **'Telefone obrigatório'**
  String get telefoneObrigatorio;

  /// No description provided for @telefoneInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Telefone inválido'**
  String get telefoneInvalido;

  /// No description provided for @minimoCaracteres.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de {n} caracteres'**
  String minimoCaracteres(Object n);

  /// No description provided for @maximoCaracteres.
  ///
  /// In pt, this message translates to:
  /// **'Máximo de {n} caracteres'**
  String maximoCaracteres(Object n);

  /// No description provided for @numeroInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Número inválido'**
  String get numeroInvalido;

  /// No description provided for @formatoInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Formato inválido'**
  String get formatoInvalido;

  /// No description provided for @fechar.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get fechar;

  /// No description provided for @sim.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get sim;

  /// No description provided for @guardar.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @salvar.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get salvar;

  /// No description provided for @todos.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get todos;

  /// No description provided for @todosText.
  ///
  /// In pt, this message translates to:
  /// **'Todos os imóveis carregados'**
  String get todosText;

  /// No description provided for @verOfertas.
  ///
  /// In pt, this message translates to:
  /// **'Ver Ofertas'**
  String get verOfertas;

  /// No description provided for @partilhar.
  ///
  /// In pt, this message translates to:
  /// **'Partilhar'**
  String get partilhar;

  /// No description provided for @copiar.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get copiar;

  /// No description provided for @copiado.
  ///
  /// In pt, this message translates to:
  /// **'Copiado!'**
  String get copiado;

  /// No description provided for @altText.
  ///
  /// In pt, this message translates to:
  /// **'Imagem do imóvel'**
  String get altText;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @telefoneLabel.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get telefoneLabel;

  /// No description provided for @whatsappLabel.
  ///
  /// In pt, this message translates to:
  /// **'WhatsApp'**
  String get whatsappLabel;

  /// No description provided for @morada.
  ///
  /// In pt, this message translates to:
  /// **'Morada'**
  String get morada;

  /// No description provided for @horario.
  ///
  /// In pt, this message translates to:
  /// **'Horário'**
  String get horario;

  /// No description provided for @permissaoNegada.
  ///
  /// In pt, this message translates to:
  /// **'Permissão negada'**
  String get permissaoNegada;

  /// No description provided for @carregando.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get carregando;

  /// No description provided for @perMes.
  ///
  /// In pt, this message translates to:
  /// **'/mês'**
  String get perMes;

  /// No description provided for @contarImoveis.
  ///
  /// In pt, this message translates to:
  /// **'{count} {count, plural, one{imóvel} other{imóveis}}'**
  String contarImoveis(num count);

  /// No description provided for @bemVindoAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo, Admin'**
  String get bemVindoAdmin;

  /// No description provided for @gestaoCompleta.
  ///
  /// In pt, this message translates to:
  /// **'Gestão completa da sua imobiliária'**
  String get gestaoCompleta;

  /// No description provided for @gerirTerrenosCard.
  ///
  /// In pt, this message translates to:
  /// **'Gerir\nTerrenos'**
  String get gerirTerrenosCard;

  /// No description provided for @editar.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get editar;

  /// No description provided for @utilizadores.
  ///
  /// In pt, this message translates to:
  /// **'Utilizadores'**
  String get utilizadores;

  /// No description provided for @contarUtilizadores.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{{count} utilizador} other{{count} utilizadores}}'**
  String contarUtilizadores(num count);

  /// No description provided for @confirmar.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirmar;

  /// No description provided for @adicionar.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get adicionar;

  /// No description provided for @bairro.
  ///
  /// In pt, this message translates to:
  /// **'Bairro'**
  String get bairro;

  /// No description provided for @churrasqueira.
  ///
  /// In pt, this message translates to:
  /// **'Churrasqueira'**
  String get churrasqueira;

  /// No description provided for @cidade.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get cidade;

  /// No description provided for @closet.
  ///
  /// In pt, this message translates to:
  /// **'Closet'**
  String get closet;

  /// No description provided for @consultor.
  ///
  /// In pt, this message translates to:
  /// **'Consultor'**
  String get consultor;

  /// No description provided for @despensa.
  ///
  /// In pt, this message translates to:
  /// **'Despensa'**
  String get despensa;

  /// No description provided for @elevador.
  ///
  /// In pt, this message translates to:
  /// **'Elevador'**
  String get elevador;

  /// No description provided for @erro.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get erro;

  /// No description provided for @erroEnviarImagem.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar imagem: {erro}'**
  String erroEnviarImagem(Object erro);

  /// No description provided for @fotos.
  ///
  /// In pt, this message translates to:
  /// **'Fotos'**
  String get fotos;

  /// No description provided for @garagemLabel.
  ///
  /// In pt, this message translates to:
  /// **'Garagem'**
  String get garagemLabel;

  /// No description provided for @guardando.
  ///
  /// In pt, this message translates to:
  /// **'Guardando...'**
  String get guardando;

  /// No description provided for @jardim.
  ///
  /// In pt, this message translates to:
  /// **'Jardim'**
  String get jardim;

  /// No description provided for @lareira.
  ///
  /// In pt, this message translates to:
  /// **'Lareira'**
  String get lareira;

  /// No description provided for @ligar.
  ///
  /// In pt, this message translates to:
  /// **'Ligar'**
  String get ligar;

  /// No description provided for @lojas.
  ///
  /// In pt, this message translates to:
  /// **'Lojas'**
  String get lojas;

  /// No description provided for @mensagemInteresseImovel.
  ///
  /// In pt, this message translates to:
  /// **'Olá! Tenho interesse no imóvel \"{title}\".'**
  String mensagemInteresseImovel(Object title);

  /// No description provided for @piscina.
  ///
  /// In pt, this message translates to:
  /// **'Piscina'**
  String get piscina;

  /// No description provided for @tipo.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get tipo;

  /// No description provided for @varanda.
  ///
  /// In pt, this message translates to:
  /// **'Varanda'**
  String get varanda;

  /// No description provided for @mensagemInteresseTerreno.
  ///
  /// In pt, this message translates to:
  /// **'Olá! Tenho interesse no terreno \"{title}\".'**
  String mensagemInteresseTerreno(Object title);

  /// No description provided for @urbanos.
  ///
  /// In pt, this message translates to:
  /// **'Urbanos'**
  String get urbanos;

  /// No description provided for @agricolas.
  ///
  /// In pt, this message translates to:
  /// **'Agrícolas'**
  String get agricolas;

  /// No description provided for @industriais.
  ///
  /// In pt, this message translates to:
  /// **'Industriais'**
  String get industriais;

  /// No description provided for @comerciais.
  ///
  /// In pt, this message translates to:
  /// **'Comerciais'**
  String get comerciais;

  /// No description provided for @lotes.
  ///
  /// In pt, this message translates to:
  /// **'Lotes'**
  String get lotes;

  /// No description provided for @semHistorico.
  ///
  /// In pt, this message translates to:
  /// **'Sem histórico'**
  String get semHistorico;

  /// No description provided for @pendente.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get pendente;

  /// No description provided for @confirmada.
  ///
  /// In pt, this message translates to:
  /// **'Confirmada'**
  String get confirmada;

  /// No description provided for @cancelada.
  ///
  /// In pt, this message translates to:
  /// **'Cancelada'**
  String get cancelada;

  /// No description provided for @data.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @exPrefiroManha.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Prefiro pela manhã...'**
  String get exPrefiroManha;

  /// No description provided for @cercado.
  ///
  /// In pt, this message translates to:
  /// **'Cercado'**
  String get cercado;

  /// No description provided for @eletricidade.
  ///
  /// In pt, this message translates to:
  /// **'Eletricidade'**
  String get eletricidade;

  /// No description provided for @flat.
  ///
  /// In pt, this message translates to:
  /// **'Flat'**
  String get flat;

  /// No description provided for @agora.
  ///
  /// In pt, this message translates to:
  /// **'Agora'**
  String get agora;

  /// No description provided for @erroEnviarAvatar.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar avatar: {erro}'**
  String erroEnviarAvatar(Object erro);

  /// No description provided for @imobiliaria.
  ///
  /// In pt, this message translates to:
  /// **'Imobiliária'**
  String get imobiliaria;

  /// No description provided for @construtora.
  ///
  /// In pt, this message translates to:
  /// **'Construtora'**
  String get construtora;

  /// No description provided for @corretor.
  ///
  /// In pt, this message translates to:
  /// **'Corretor'**
  String get corretor;

  /// No description provided for @outro.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get outro;

  /// No description provided for @parceiro.
  ///
  /// In pt, this message translates to:
  /// **'Parceiro'**
  String get parceiro;

  /// No description provided for @contactos.
  ///
  /// In pt, this message translates to:
  /// **'Contactos'**
  String get contactos;

  /// No description provided for @insiraEmailPasse.
  ///
  /// In pt, this message translates to:
  /// **'Insira o email e a sua passe de acesso'**
  String get insiraEmailPasse;

  /// No description provided for @passeAcesso.
  ///
  /// In pt, this message translates to:
  /// **'Passe de acesso'**
  String get passeAcesso;

  /// No description provided for @passeHint.
  ///
  /// In pt, this message translates to:
  /// **'6 dígitos'**
  String get passeHint;

  /// No description provided for @insiraPasse.
  ///
  /// In pt, this message translates to:
  /// **'Insira a sua passe de acesso'**
  String get insiraPasse;

  /// No description provided for @passe6Digitos.
  ///
  /// In pt, this message translates to:
  /// **'A passe deve ter 6 dígitos'**
  String get passe6Digitos;

  /// No description provided for @passeIncorreta.
  ///
  /// In pt, this message translates to:
  /// **'Email ou passe de acesso incorretos'**
  String get passeIncorreta;

  /// No description provided for @entrar.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get entrar;

  /// No description provided for @erroEntrar.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao entrar. Verifique a ligação e tente novamente.'**
  String get erroEntrar;

  /// No description provided for @videos.
  ///
  /// In pt, this message translates to:
  /// **'Vídeos'**
  String get videos;

  /// No description provided for @adicionarVideo.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar vídeo'**
  String get adicionarVideo;

  /// No description provided for @nenhumVideoSelecionado.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vídeo selecionado'**
  String get nenhumVideoSelecionado;

  /// No description provided for @erroEnviarVideo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar vídeo: {erro}'**
  String erroEnviarVideo(Object erro);

  /// No description provided for @erroCarregarVideo.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o vídeo'**
  String get erroCarregarVideo;

  /// No description provided for @limiteVideos.
  ///
  /// In pt, this message translates to:
  /// **'Limite de {max} vídeos atingido'**
  String limiteVideos(Object max);

  /// No description provided for @videoMuitoGrande.
  ///
  /// In pt, this message translates to:
  /// **'O vídeo é demasiado grande (máx. {max} MB).'**
  String videoMuitoGrande(Object max);

  /// No description provided for @erroSelecionarVideo.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível selecionar o vídeo. Tente novamente.'**
  String get erroSelecionarVideo;

  /// No description provided for @descobrir.
  ///
  /// In pt, this message translates to:
  /// **'Descobrir'**
  String get descobrir;

  /// No description provided for @descobrirDeslizar.
  ///
  /// In pt, this message translates to:
  /// **'Deslize para cima para ver mais imóveis'**
  String get descobrirDeslizar;

  /// No description provided for @descobrirVazioTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sem imóveis para descobrir'**
  String get descobrirVazioTitulo;

  /// No description provided for @descobrirVazioSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Volte mais tarde para ver novos imóveis.'**
  String get descobrirVazioSubtitulo;

  /// No description provided for @descobrirErro.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o feed.'**
  String get descobrirErro;

  /// No description provided for @contactar.
  ///
  /// In pt, this message translates to:
  /// **'Contactar'**
  String get contactar;

  /// No description provided for @welcomeHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Mais que imóveis. É o seu próximo capítulo.'**
  String get welcomeHeadline;

  /// No description provided for @whyChooseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Por que escolher o Luar Mobiliário?'**
  String get whyChooseTitle;

  /// No description provided for @featVideosTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vídeos em alta definição'**
  String get featVideosTitle;

  /// No description provided for @featVideosDesc.
  ///
  /// In pt, this message translates to:
  /// **'Veja os imóveis como se estivesse lá.'**
  String get featVideosDesc;

  /// No description provided for @featVerticalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Navegação vertical'**
  String get featVerticalTitle;

  /// No description provided for @featVerticalDesc.
  ///
  /// In pt, this message translates to:
  /// **'Deslize para cima e descubra o próximo imóvel.'**
  String get featVerticalDesc;

  /// No description provided for @featSearchTitle.
  ///
  /// In pt, this message translates to:
  /// **'Busca inteligente'**
  String get featSearchTitle;

  /// No description provided for @featSearchDesc.
  ///
  /// In pt, this message translates to:
  /// **'Encontre exatamente o que procura.'**
  String get featSearchDesc;

  /// No description provided for @featMapTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mapa interativo'**
  String get featMapTitle;

  /// No description provided for @featMapDesc.
  ///
  /// In pt, this message translates to:
  /// **'Veja a localização e arredores.'**
  String get featMapDesc;

  /// No description provided for @featContactTitle.
  ///
  /// In pt, this message translates to:
  /// **'Contacto direto'**
  String get featContactTitle;

  /// No description provided for @featContactDesc.
  ///
  /// In pt, this message translates to:
  /// **'Fale com o anunciante via WhatsApp ou telefone.'**
  String get featContactDesc;

  /// No description provided for @featFavoritesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos e histórico'**
  String get featFavoritesTitle;

  /// No description provided for @featFavoritesDesc.
  ///
  /// In pt, this message translates to:
  /// **'Guarde os imóveis que mais gosta.'**
  String get featFavoritesDesc;

  /// No description provided for @featNotificationsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações em tempo real'**
  String get featNotificationsTitle;

  /// No description provided for @featNotificationsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Não perca novas oportunidades.'**
  String get featNotificationsDesc;

  /// No description provided for @comparar.
  ///
  /// In pt, this message translates to:
  /// **'Comparar'**
  String get comparar;

  /// No description provided for @comparando.
  ///
  /// In pt, this message translates to:
  /// **'Comparando'**
  String get comparando;

  /// No description provided for @adicionarComparacao.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar à comparação'**
  String get adicionarComparacao;

  /// No description provided for @limiteComparacao.
  ///
  /// In pt, this message translates to:
  /// **'Máximo de 3 imóveis na comparação.'**
  String get limiteComparacao;

  /// No description provided for @imovelAdicionadoComparacao.
  ///
  /// In pt, this message translates to:
  /// **'Imóvel adicionado à comparação ({count}/3)'**
  String imovelAdicionadoComparacao(Object count);

  /// No description provided for @comparacaoVaziaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sem imóveis para comparar'**
  String get comparacaoVaziaTitulo;

  /// No description provided for @comparacaoVaziaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Adicione imóveis à comparação para os ver lado a lado.'**
  String get comparacaoVaziaSubtitulo;

  /// No description provided for @destaques.
  ///
  /// In pt, this message translates to:
  /// **'Destaques'**
  String get destaques;

  /// No description provided for @maisBarato.
  ///
  /// In pt, this message translates to:
  /// **'Mais barato'**
  String get maisBarato;

  /// No description provided for @melhorValor.
  ///
  /// In pt, this message translates to:
  /// **'Melhor valor'**
  String get melhorValor;

  /// No description provided for @imagens.
  ///
  /// In pt, this message translates to:
  /// **'Imagens'**
  String get imagens;

  /// No description provided for @acoes.
  ///
  /// In pt, this message translates to:
  /// **'Ações'**
  String get acoes;

  /// No description provided for @limparComparacao.
  ///
  /// In pt, this message translates to:
  /// **'Limpar comparação'**
  String get limparComparacao;

  /// No description provided for @limparComparacaoConfirmacao.
  ///
  /// In pt, this message translates to:
  /// **'Remover todos os imóveis da comparação?'**
  String get limparComparacaoConfirmacao;

  /// No description provided for @precoPorM2.
  ///
  /// In pt, this message translates to:
  /// **'Preço por m²'**
  String get precoPorM2;

  /// No description provided for @verImovel.
  ///
  /// In pt, this message translates to:
  /// **'Ver imóvel'**
  String get verImovel;

  /// No description provided for @filtros.
  ///
  /// In pt, this message translates to:
  /// **'Filtros'**
  String get filtros;

  /// No description provided for @finalidade.
  ///
  /// In pt, this message translates to:
  /// **'Finalidade'**
  String get finalidade;

  /// No description provided for @residencial.
  ///
  /// In pt, this message translates to:
  /// **'Residencial'**
  String get residencial;

  /// No description provided for @minimo.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo'**
  String get minimo;

  /// No description provided for @maximo.
  ///
  /// In pt, this message translates to:
  /// **'Máximo'**
  String get maximo;

  /// No description provided for @meusAnuncios.
  ///
  /// In pt, this message translates to:
  /// **'Os meus anúncios'**
  String get meusAnuncios;

  /// No description provided for @definicoes.
  ///
  /// In pt, this message translates to:
  /// **'Definições'**
  String get definicoes;

  /// No description provided for @verificado.
  ///
  /// In pt, this message translates to:
  /// **'Verificado'**
  String get verificado;

  /// No description provided for @anuncios.
  ///
  /// In pt, this message translates to:
  /// **'Anúncios'**
  String get anuncios;

  /// No description provided for @novoAnuncio.
  ///
  /// In pt, this message translates to:
  /// **'Novo anúncio'**
  String get novoAnuncio;

  /// No description provided for @semAnuncios.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tem anúncios'**
  String get semAnuncios;

  /// No description provided for @semAnunciosSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Publique um imóvel para começar a receber contactos.'**
  String get semAnunciosSubtitulo;

  /// No description provided for @anuncioAtivo.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get anuncioAtivo;

  /// No description provided for @anuncioInativo.
  ///
  /// In pt, this message translates to:
  /// **'Inativo'**
  String get anuncioInativo;

  /// No description provided for @ativar.
  ///
  /// In pt, this message translates to:
  /// **'Ativar'**
  String get ativar;

  /// No description provided for @desativar.
  ///
  /// In pt, this message translates to:
  /// **'Desativar'**
  String get desativar;

  /// No description provided for @arrendar.
  ///
  /// In pt, this message translates to:
  /// **'Arrendar'**
  String get arrendar;

  /// No description provided for @reportar.
  ///
  /// In pt, this message translates to:
  /// **'Reportar'**
  String get reportar;

  /// No description provided for @reportarAnuncio.
  ///
  /// In pt, this message translates to:
  /// **'Reportar anúncio'**
  String get reportarAnuncio;

  /// No description provided for @motivo.
  ///
  /// In pt, this message translates to:
  /// **'Motivo'**
  String get motivo;

  /// No description provided for @detalhesOpcionais.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes (opcional)'**
  String get detalhesOpcionais;

  /// No description provided for @enviarDenuncia.
  ///
  /// In pt, this message translates to:
  /// **'Enviar denúncia'**
  String get enviarDenuncia;

  /// No description provided for @denunciaEnviada.
  ///
  /// In pt, this message translates to:
  /// **'Denúncia enviada. Obrigado pela ajuda.'**
  String get denunciaEnviada;

  /// No description provided for @erroEnviarDenuncia.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar denúncia'**
  String get erroEnviarDenuncia;

  /// No description provided for @selecionarMotivo.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um motivo'**
  String get selecionarMotivo;

  /// No description provided for @motivoSpam.
  ///
  /// In pt, this message translates to:
  /// **'Spam'**
  String get motivoSpam;

  /// No description provided for @motivoInformacaoFalsa.
  ///
  /// In pt, this message translates to:
  /// **'Informação falsa'**
  String get motivoInformacaoFalsa;

  /// No description provided for @motivoConteudoInapropriado.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo impróprio'**
  String get motivoConteudoInapropriado;

  /// No description provided for @motivoBurla.
  ///
  /// In pt, this message translates to:
  /// **'Burla / fraude'**
  String get motivoBurla;

  /// No description provided for @motivoOutro.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get motivoOutro;

  /// No description provided for @denuncias.
  ///
  /// In pt, this message translates to:
  /// **'Denúncias'**
  String get denuncias;

  /// No description provided for @semDenuncias.
  ///
  /// In pt, this message translates to:
  /// **'Sem denúncias'**
  String get semDenuncias;

  /// No description provided for @todasAsOpcoes.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get todasAsOpcoes;

  /// No description provided for @emAnalise.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get emAnalise;

  /// No description provided for @resolvida.
  ///
  /// In pt, this message translates to:
  /// **'Resolvida'**
  String get resolvida;

  /// No description provided for @dispensada.
  ///
  /// In pt, this message translates to:
  /// **'Dispensada'**
  String get dispensada;

  /// No description provided for @denunciadoPor.
  ///
  /// In pt, this message translates to:
  /// **'Denunciado por'**
  String get denunciadoPor;

  /// No description provided for @ocultarAnuncio.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar anúncio'**
  String get ocultarAnuncio;

  /// No description provided for @anuncioOcultado.
  ///
  /// In pt, this message translates to:
  /// **'Anúncio ocultado'**
  String get anuncioOcultado;

  /// No description provided for @verificarAnunciante.
  ///
  /// In pt, this message translates to:
  /// **'Verificar anunciante'**
  String get verificarAnunciante;

  /// No description provided for @retirarVerificacao.
  ///
  /// In pt, this message translates to:
  /// **'Retirar verificação'**
  String get retirarVerificacao;

  /// No description provided for @anuncianteVerificado.
  ///
  /// In pt, this message translates to:
  /// **'Anunciante verificado'**
  String get anuncianteVerificado;

  /// No description provided for @verificacaoAlterada.
  ///
  /// In pt, this message translates to:
  /// **'Verificação alterada'**
  String get verificacaoAlterada;

  /// No description provided for @erroVerificacao.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao alterar verificação'**
  String get erroVerificacao;

  /// No description provided for @marcarResolvida.
  ///
  /// In pt, this message translates to:
  /// **'Marcar resolvida'**
  String get marcarResolvida;

  /// No description provided for @dispensar.
  ///
  /// In pt, this message translates to:
  /// **'Dispensar'**
  String get dispensar;

  /// No description provided for @erroAcaoModeracao.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao executar ação de moderação'**
  String get erroAcaoModeracao;

  /// No description provided for @acaoConcluida.
  ///
  /// In pt, this message translates to:
  /// **'Ação concluída'**
  String get acaoConcluida;

  /// No description provided for @reportarRequerLogin.
  ///
  /// In pt, this message translates to:
  /// **'Inicie sessão para reportar anúncios'**
  String get reportarRequerLogin;

  /// No description provided for @semLigacao.
  ///
  /// In pt, this message translates to:
  /// **'Sem ligação à internet'**
  String get semLigacao;

  /// No description provided for @reproducaoAutomatica.
  ///
  /// In pt, this message translates to:
  /// **'Reprodução automática'**
  String get reproducaoAutomatica;

  /// No description provided for @reproducaoAutomaticaDesc.
  ///
  /// In pt, this message translates to:
  /// **'Reproduzir vídeos do feed sem toque'**
  String get reproducaoAutomaticaDesc;

  /// No description provided for @avaliacoes.
  ///
  /// In pt, this message translates to:
  /// **'Avaliações'**
  String get avaliacoes;

  /// No description provided for @avaliar.
  ///
  /// In pt, this message translates to:
  /// **'Avaliar'**
  String get avaliar;

  /// No description provided for @avaliarImovel.
  ///
  /// In pt, this message translates to:
  /// **'Avaliar imóvel'**
  String get avaliarImovel;

  /// No description provided for @atualizarAvaliacao.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar avaliação'**
  String get atualizarAvaliacao;

  /// No description provided for @semAvaliacoes.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem avaliações'**
  String get semAvaliacoes;

  /// No description provided for @avaliacoesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} avaliações'**
  String avaliacoesCount(int count);

  /// No description provided for @avaliacaoRequerLogin.
  ///
  /// In pt, this message translates to:
  /// **'Inicie sessão para avaliar'**
  String get avaliacaoRequerLogin;

  /// No description provided for @avaliacaoInvalida.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma classificação de 1 a 5'**
  String get avaliacaoInvalida;

  /// No description provided for @avaliacaoEnviada.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação enviada'**
  String get avaliacaoEnviada;

  /// No description provided for @erroAvaliacao.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar avaliação'**
  String get erroAvaliacao;

  /// No description provided for @escrevaComentario.
  ///
  /// In pt, this message translates to:
  /// **'Escreva o seu comentário (opcional)'**
  String get escrevaComentario;

  /// No description provided for @enviarAvaliacao.
  ///
  /// In pt, this message translates to:
  /// **'Enviar avaliação'**
  String get enviarAvaliacao;

  /// No description provided for @analise.
  ///
  /// In pt, this message translates to:
  /// **'Análise'**
  String get analise;

  /// No description provided for @carregandoAnalise.
  ///
  /// In pt, this message translates to:
  /// **'A carregar análise...'**
  String get carregandoAnalise;

  /// No description provided for @novosUtilizadores30d.
  ///
  /// In pt, this message translates to:
  /// **'Novos utilizadores (30 dias)'**
  String get novosUtilizadores30d;

  /// No description provided for @agendamentosPendentes.
  ///
  /// In pt, this message translates to:
  /// **'Agendamentos pendentes'**
  String get agendamentosPendentes;

  /// No description provided for @precoMedioVenda.
  ///
  /// In pt, this message translates to:
  /// **'Preço médio (venda)'**
  String get precoMedioVenda;

  /// No description provided for @maisVistos.
  ///
  /// In pt, this message translates to:
  /// **'Anúncios mais vistos'**
  String get maisVistos;

  /// No description provided for @visualizacoes.
  ///
  /// In pt, this message translates to:
  /// **'visualizações'**
  String get visualizacoes;

  /// No description provided for @semVisualizacoes.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem visualizações.'**
  String get semVisualizacoes;

  /// No description provided for @porTipo.
  ///
  /// In pt, this message translates to:
  /// **'Anúncios por tipo'**
  String get porTipo;

  /// No description provided for @semFotos.
  ///
  /// In pt, this message translates to:
  /// **'Sem fotos disponíveis'**
  String get semFotos;

  /// No description provided for @semVideos.
  ///
  /// In pt, this message translates to:
  /// **'Sem vídeos disponíveis'**
  String get semVideos;

  /// No description provided for @seguidores.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get seguidores;

  /// No description provided for @aprovacao.
  ///
  /// In pt, this message translates to:
  /// **'Aprovação'**
  String get aprovacao;

  /// No description provided for @renovar.
  ///
  /// In pt, this message translates to:
  /// **'Renovar'**
  String get renovar;

  /// No description provided for @recentrar.
  ///
  /// In pt, this message translates to:
  /// **'Recentrar mapa'**
  String get recentrar;

  /// No description provided for @semImoveisNoMapa.
  ///
  /// In pt, this message translates to:
  /// **'Sem imóveis para mostrar no mapa'**
  String get semImoveisNoMapa;

  /// No description provided for @verNoMapa.
  ///
  /// In pt, this message translates to:
  /// **'Ver no mapa'**
  String get verNoMapa;

  /// No description provided for @vendido.
  ///
  /// In pt, this message translates to:
  /// **'Vendido'**
  String get vendido;

  /// No description provided for @arrendado.
  ///
  /// In pt, this message translates to:
  /// **'Arrendado'**
  String get arrendado;

  /// No description provided for @historicoDesc.
  ///
  /// In pt, this message translates to:
  /// **'Os imóveis que consultar ficam guardados aqui.'**
  String get historicoDesc;

  /// No description provided for @renovado.
  ///
  /// In pt, this message translates to:
  /// **'Renovado'**
  String get renovado;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
